import AVFoundation
import Combine
import SwiftUI

@MainActor
public final class DCameraController: NSObject, ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false

    private nonisolated let session = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = .init(
        session: self.session
    )
    private var output = AVCapturePhotoOutput()
    private var capturePhotoCompletion: ((UIImage) -> Void)?

    override public init() {
        super.init()
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(self.output)
        else {
            return
        }
        session.addInput(input)
        session.addOutput(output)
        previewLayer.videoGravity = .resizeAspectFill
        session.commitConfiguration()
        isLoading = false
        isRunning = true
    }

    public func startSession() {
        if session.isRunning { return }
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        }
    }

    public func stopSession() {
        if !session.isRunning { return }
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    public func takePhoto(
        completion: @escaping (UIImage) -> Void
    ) {
        isCapturing = true
        capturePhotoCompletion = completion
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(
            with: settings,
            delegate: self
        )
    }
}

extension DCameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error _: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            return
        }
        capturePhotoCompletion?(image)
        isCapturing = false
    }
}

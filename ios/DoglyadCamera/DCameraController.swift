import SwiftUI
import Combine
import AVFoundation

@MainActor
public final class DCameraController: NSObject, ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false
    
    nonisolated private let session = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(
        session: self.session
    )
    private var output = AVCapturePhotoOutput()
    private var capturePhotoCompletion: ((UIImage) -> Void)?
    
    public override init() {
        super.init()
        self.session.beginConfiguration()
        guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ),
            let input = try? AVCaptureDeviceInput(device: device),
            self.session.canAddInput(input),
            self.session.canAddOutput(self.output) else {
            return
        }
        self.session.addInput(input)
        self.session.addOutput(self.output)
        self.previewLayer.videoGravity = .resizeAspectFill
        self.session.commitConfiguration()
        self.isLoading = false
        self.isRunning = true
    }

    public func startSession() -> Void {
        if self.session.isRunning { return }
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        }
    }

    public func stopSession() -> Void {
        if !self.session.isRunning { return }
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    public func takePhoto(
        completion: @escaping (UIImage) -> Void
    ) -> Void {
        self.isCapturing = true
        self.capturePhotoCompletion = completion
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(
            with: settings,
            delegate: self
        )
    }
}

extension DCameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) -> Void {
        guard let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) else {
            return
        }
        self.capturePhotoCompletion?(image)
        self.isCapturing = false
    }
}

import AVFoundation
import Combine
import SwiftUI

@MainActor
public final class DCameraController: ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false

    private nonisolated let session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    private var output = AVCapturePhotoOutput()
    private let device = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: .back
    )!
    private lazy var input = try! AVCaptureDeviceInput(device: device)

    private lazy var delegate = PhotoCaptureDelegate(controller: self)
    private var capturePhotoCompletion: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.doglyad.camera.session", qos: .background)

    public init() {
        guard session.canAddInput(input),
              session.canAddOutput(output)
        else {
            return
        }

        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill

        session.beginConfiguration()
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        isLoading = false
    }

    public func startSession() {
        guard !isRunning else { return }
        isRunning = true
        sessionQueue.async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.previewLayer.connection?.isEnabled = true
            }
        }
    }

    public func stopSession() {
        guard isRunning else { return }
        isRunning = false
        sessionQueue.async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.previewLayer.connection?.isEnabled = false
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
            delegate: delegate
        )
    }

    fileprivate func handlePhotoCaptured(image: UIImage) {
        capturePhotoCompletion?(image)
        isCapturing = false
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private var controller: DCameraController

    init(
        controller: DCameraController
    ) {
        self.controller = controller
    }

    func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error _: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            return
        }
        Task { @MainActor in
            controller.handlePhotoCaptured(image: image)
        }
    }
}

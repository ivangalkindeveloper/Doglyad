import AVFoundation
import SwiftUI
import Combine

@MainActor
public final class DCameraController: ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false

    private nonisolated let session = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = .init(
        session: self.session
    )
    private var output = AVCapturePhotoOutput()
    private var capturePhotoCompletion: ((UIImage) -> Void)?
    private lazy var delegate = PhotoCaptureDelegate(controller: self)
    private let sessionQueue = DispatchQueue(label: "com.doglyad.camera.session", qos: .background)

    public init() {
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
    private weak var controller: DCameraController?

    init(controller: DCameraController) {
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
            controller?.handlePhotoCaptured(image: image)
        }
    }
}

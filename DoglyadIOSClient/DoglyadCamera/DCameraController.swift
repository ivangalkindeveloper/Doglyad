import SwiftUI
import Combine
import AVFoundation

public final class DCameraController: NSObject, ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false
    
    let session = AVCaptureSession()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(
        session: self.session
    )
    private let sessionQueue = DispatchQueue(label: "com.scan.camera.queue")
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
        self.startSession()
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }


    public func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isRunning = true
                }
            }
        }
    }

    public func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isRunning = false
                }
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
    ) {
        guard let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) else {
            return
        }
        self.capturePhotoCompletion?(image)
        self.isCapturing = false
    }
}

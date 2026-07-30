import AVFoundation
import Combine
import CoreImage
import ImageIO
import SwiftUI

@MainActor
public final class DCameraController: ObservableObject {
    @Published public var isLoading = true
    @Published public var isRunning = false
    @Published public var isCapturing = false

    private nonisolated let session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    private nonisolated let output = AVCapturePhotoOutput()
    private nonisolated let delegate = PhotoCaptureDelegate()

    private var capturePhotoCompletion: ((UIImage) -> Void)?

    private nonisolated let sessionQueue = DispatchQueue(
        label: "com.doglyad.camera.session",
        qos: .userInitiated
    )

    public init() {
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        delegate.controller = self
        configureSession()
    }

    public func startSession() {
        guard !isRunning else { return }
        isRunning = true
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            if !self.session.isRunning {
                self.session.startRunning()
            }
            let isRunning = self.session.isRunning
            Task { @MainActor in
                self.isRunning = isRunning
                self.previewLayer.connection?.isEnabled = isRunning
            }
        }
    }

    public func stopSession() {
        guard isRunning else { return }
        isRunning = false
        previewLayer.connection?.isEnabled = false
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    public func takePhoto(
        completion: @escaping (UIImage) -> Void
    ) {
        guard !isCapturing else { return }

        isCapturing = true
        capturePhotoCompletion = completion

        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            // Очередь последовательная, поэтому конфигурация и startRunning()
            // здесь уже гарантированно завершены — снимок не уходит в сессию,
            // у которой ещё нет активного соединения.
            guard self.session.isRunning,
                  let connection = self.output.connection(with: .video),
                  connection.isActive,
                  connection.isEnabled
            else {
                Task { @MainActor in
                    self.handleCaptureFailed()
                }
                return
            }

            self.output.capturePhoto(
                with: Self.makeSettings(output: self.output),
                delegate: self.delegate
            )
        }
    }

    fileprivate func handlePhotoCaptured(image: UIImage) {
        isCapturing = false
        let completion = capturePhotoCompletion
        capturePhotoCompletion = nil
        completion?(image)
    }

    fileprivate func handleCaptureFailed() {
        isCapturing = false
        capturePhotoCompletion = nil
    }
}

private extension DCameraController {
    func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            Self.configure(
                session: self.session,
                output: self.output
            )
            self.delegate.prepare()
            Task { @MainActor in
                self.isLoading = false
            }
        }
    }

    nonisolated static func configure(
        session: AVCaptureSession,
        output: AVCapturePhotoOutput
    ) {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            return
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        guard session.canAddInput(input),
              session.canAddOutput(output)
        else {
            return
        }
        session.addInput(input)
        session.addOutput(output)

        // Кадр всё равно уменьшается до scanPhotoResizeMaxDimension, поэтому
        // 1080p с запасом хватает и для сети, и для превью. Пресет .photo
        // заставил бы ISP обрабатывать полный сенсорный кадр.
        if session.canSetSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        }

        // .balanced включает мультикадровое слияние и ожидание стабилизации
        // сцены — это основная задержка затвора. .speed снимает один кадр.
        output.maxPhotoQualityPrioritization = .speed
        if output.isZeroShutterLagSupported {
            output.isZeroShutterLagEnabled = true
        }
        if output.isResponsiveCaptureSupported {
            output.isResponsiveCaptureEnabled = true
        }
        if output.isFastCapturePrioritizationSupported {
            output.isFastCapturePrioritizationEnabled = true
        }
    }

    nonisolated static func makeSettings(
        output: AVCapturePhotoOutput
    ) -> AVCapturePhotoSettings {
        let settings: AVCapturePhotoSettings

        // Несжатый буфер убирает HEIC-энкод и последующий декод: UIImage
        // собирается из пикселей напрямую.
        if output.availablePhotoPixelFormatTypes.contains(kCVPixelFormatType_32BGRA) {
            settings = AVCapturePhotoSettings(
                format: [
                    kCVPixelBufferPixelFormatTypeKey as String: NSNumber(
                        value: kCVPixelFormatType_32BGRA
                    ),
                ]
            )
        } else {
            settings = AVCapturePhotoSettings()
        }

        settings.photoQualityPrioritization = .speed
        settings.flashMode = .off
        if output.isAutoRedEyeReductionSupported {
            settings.isAutoRedEyeReductionEnabled = false
        }

        return settings
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    weak var controller: DCameraController?

    // Колбэки AVFoundation приходят на одну последовательную внутреннюю
    // очередь, поэтому ленивая инициализация здесь безопасна.
    private lazy var ciContext = CIContext(options: [.useSoftwareRenderer: false])

    /// Прогревает CIContext вне пути захвата, чтобы первый снимок не платил
    /// за его создание.
    func prepare() {
        _ = ciContext
    }

    func photoOutput(
        _: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let image = makeImage(from: photo)
        else {
            Task { @MainActor [controller] in
                controller?.handleCaptureFailed()
            }
            return
        }

        Task { @MainActor [controller] in
            controller?.handlePhotoCaptured(image: image)
        }
    }

    /// Собирает полностью декодированный UIImage из пиксельного буфера, минуя
    /// кодек. Ориентация берётся из метаданных кадра — у несжатого буфера она
    /// не применена, в отличие от EXIF в fileDataRepresentation().
    private func makeImage(
        from photo: AVCapturePhoto
    ) -> UIImage? {
        guard let pixelBuffer = photo.pixelBuffer else {
            guard let data = photo.fileDataRepresentation() else { return nil }
            return UIImage(data: data)?.preparingForDisplay()
        }

        let orientation = (photo.metadata[kCGImagePropertyOrientation as String] as? UInt32)
            .flatMap(CGImagePropertyOrientation.init)
            ?? .up
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

import AVFoundation
import Combine
import Foundation
import Speech

/// Распознавание речи на новом стеке `SpeechAnalyzer` (iOS 26+).
///
/// В отличие от `SFSpeechRecognizer` работает локально, без лимита в минуту и с
/// потоковыми результатами, что лучше подходит для длинных диктовок осмотров.
/// Модель языка при необходимости догружается через ``AssetInventory``.
@available(iOS 26.0, *)
@MainActor
public final class DSpeechControllerAnalyzer: DSpeechControllerProtocol {
    /// Поддерживает ли `SpeechTranscriber` данную локаль. Асинхронно, потому что
    /// список локалей (`SpeechTranscriber.supportedLocales`) отдаётся `await`.
    /// Фабрика спрашивает это до выбора реализации и на непокрытой локали (как
    /// `ru-RU`) откатывается к `SFSpeechRecognizer`.
    public static func isSupported(
        locale: Locale
    ) async -> Bool {
        await resolvedLocale(for: locale) != nil
    }

    /// Подбирает поддерживаемую локаль: точное BCP-47 совпадение, иначе тот же
    /// язык (сначала с тем же регионом, затем любой регион этого языка). Так
    /// «русский с не-RU регионом» нашёл бы `ru-RU`, а неподдержанный язык — nil.
    private static func resolvedLocale(
        for locale: Locale
    ) async -> Locale? {
        let supported = await SpeechTranscriber.supportedLocales

        let target = locale.identifier(.bcp47)
        if let exact = supported.first(where: { $0.identifier(.bcp47) == target }) {
            return exact
        }

        guard let language = locale.language.languageCode?.identifier else { return nil }
        let region = locale.region?.identifier
        if let regional = supported.first(where: {
            $0.language.languageCode?.identifier == language && $0.region?.identifier == region
        }) {
            return regional
        }

        return supported.first { $0.language.languageCode?.identifier == language }
    }

    private let locale: Locale
    private let audioSession = AVAudioSession.sharedInstance()
    private let audioEngine = AVAudioEngine()
    private let converter = DSpeechBufferConverter()

    private var analyzer: SpeechAnalyzer?
    private var transcriber: SpeechTranscriber?
    private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
    private var analyzerFormat: AVAudioFormat?
    private var recognizerTask: Task<Void, Never>?
    private var startTask: Task<Void, Never>?

    /// Накопленный финализированный текст: к нему добавляем «черновой» кусок
    /// текущей фразы, чтобы на экране была видна речь в реальном времени.
    private var finalizedText = AttributedString()

    @Published public var status: DRecordingStatus = .stopped
    @Published public var text: String?
    @Published public var audioMeter: Float = 0.0

    public init(
        locale: Locale
    ) {
        self.locale = locale
    }

    public func start() {
        guard status != .recording else { return }

        status = .recording
        text = nil
        audioMeter = 0.0
        finalizedText = AttributedString()

        startTask = Task { [weak self] in
            do {
                try await self?.beginTranscription()
            } catch {
                self?.stop()
            }
        }
    }

    public func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        inputBuilder?.finish()
        inputBuilder = nil
        status = .stopped

        startTask?.cancel()
        startTask = nil

        // Даём анализатору доработать хвост аудио и выдать финальный результат,
        // и только потом отпускаем поток результатов.
        let analyzer = analyzer
        let recognizerTask = recognizerTask
        self.analyzer = nil
        transcriber = nil
        self.recognizerTask = nil
        Task {
            try? await analyzer?.finalizeAndFinishThroughEndOfInput()
            recognizerTask?.cancel()
        }
    }

    private func beginTranscription() async throws {
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Локаль устройства может отличаться регионом от поддерживаемой (или не
        // поддерживаться вовсе) — подбираем ту, что реально знает транскрайбер.
        // В обычном потоке фабрика уже проверила поддержку, так что nil здесь —
        // подстраховка.
        guard let resolvedLocale = await Self.resolvedLocale(for: locale) else {
            throw DSpeechError.unavailable
        }

        let transcriber = SpeechTranscriber(
            locale: resolvedLocale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )
        self.transcriber = transcriber

        let analyzer = SpeechAnalyzer(modules: [transcriber])
        self.analyzer = analyzer

        try await installModelIfNeeded(transcriber: transcriber, locale: resolvedLocale)

        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])

        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputBuilder = inputBuilder

        // Потоковые результаты: финальные фразы копим, черновую дописываем сверху.
        recognizerTask = Task { [weak self] in
            do {
                for try await result in transcriber.results {
                    guard let self else { return }
                    if result.isFinal {
                        self.finalizedText += result.text
                        self.text = String(self.finalizedText.characters)
                    } else {
                        self.text = String((self.finalizedText + result.text).characters)
                    }
                }
            } catch {
                self?.stop()
            }
        }

        try await analyzer.start(inputSequence: inputSequence)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        let converter = converter
        let analyzerFormat = analyzerFormat
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.updateAudioMeter(buffer)

            guard let analyzerFormat else { return }
            guard let converted = try? converter.convert(buffer, to: analyzerFormat) else { return }
            inputBuilder.yield(AnalyzerInput(buffer: converted))
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    /// Догружает языковую модель для локали, если её ещё нет на устройстве.
    private func installModelIfNeeded(
        transcriber: SpeechTranscriber,
        locale: Locale
    ) async throws {
        let identifier = locale.identifier(.bcp47)
        let installed = await SpeechTranscriber.installedLocales
        guard !installed.contains(where: { $0.identifier(.bcp47) == identifier }) else {
            return
        }

        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }
    }

    private func updateAudioMeter(
        _ buffer: AVAudioPCMBuffer
    ) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(
            start: channelData,
            count: Int(buffer.frameLength)
        )
        )

        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let level = rms * 15

        DispatchQueue.main.async {
            self.audioMeter = min(max(level, 0), 1)
        }
    }
}

/// Приводит буферы микрофона к формату, который ждёт `SpeechAnalyzer`.
private final class DSpeechBufferConverter {
    private var converter: AVAudioConverter?

    func convert(
        _ buffer: AVAudioPCMBuffer,
        to format: AVAudioFormat
    ) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format
        guard inputFormat != format else { return buffer }

        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: inputFormat, to: format)
            converter?.primeMethod = .none
        }
        guard let converter else {
            throw DSpeechError.unavailable
        }

        let ratio = converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let frameCapacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up))
        guard let output = AVAudioPCMBuffer(
            pcmFormat: converter.outputFormat,
            frameCapacity: frameCapacity
        ) else {
            throw DSpeechError.unavailable
        }

        var error: NSError?
        var consumed = false
        let status = converter.convert(to: output, error: &error) { _, inputStatus in
            defer { consumed = true }
            inputStatus.pointee = consumed ? .noDataNow : .haveData
            return consumed ? nil : buffer
        }
        guard status != .error else {
            throw DSpeechError.unavailable
        }

        return output
    }
}

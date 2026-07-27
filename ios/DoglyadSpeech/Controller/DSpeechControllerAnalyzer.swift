import AVFoundation
import Combine
import Foundation
import Speech

/// Распознавание речи на новом стеке `SpeechAnalyzer` (iOS 26+).
///
/// Работает локально, без лимита в минуту и с потоковыми результатами, что
/// лучше подходит для длинных диктовок осмотров. Модель языка при необходимости
/// догружается через ``AssetInventory`` — на это время сессия остаётся в статусе
/// `preparing`, микрофон ещё не пишет.
///
/// Модулем распознавания взят `DictationTranscriber`, а не `SpeechTranscriber`:
/// только он читает `AnalysisContext.contextualStrings` (`SpeechTranscriber`
/// молча их игнорирует) и только у него есть подсказка `.farField` — а телефон
/// врача часто лежит на аппарате в стороне, а не находится у рта.
@available(iOS 26.0, *)
@MainActor
public final class DSpeechControllerAnalyzer: DSpeechControllerProtocol {
    /// Размер буфера тапа. При 48 кГц это примерно 21 мс звука.
    private static let tapBufferSize: AVAudioFrameCount = 1024
    /// Сколько ждём, пока анализатор доработает хвост аудио после остановки.
    private static let finalizationTimeout: Duration = .seconds(3)

    /// Поддерживает ли транскрайбер данную локаль. Асинхронно, потому что
    /// список локалей отдаётся `await`. Фабрика спрашивает это до выбора
    /// реализации и на непокрытой локали откатывается к `SFSpeechRecognizer`.
    public static func isSupported(
        locale: Locale
    ) async -> Bool {
        await DictationTranscriber.supportedLocale(equivalentTo: locale) != nil
    }

    private let locale: Locale
    /// Лексика осмотра: специфичные термины, которые распознаватель иначе
    /// стабильно слышит мимо.
    private let contextualStrings: [String]
    /// Та же лексика как пост-обработка: подсказки смещают распознавание,
    /// а корректор чинит то, что всё равно услышалось мимо.
    private let corrector: DSpeechLexiconCorrector
    /// Пересоздаётся на каждую сессию: голосовую обработку можно переключать
    /// только на остановленном движке, а её состояние переживает `stop()` и на
    /// повторном старте с другим маршрутом звука приводит к невалидному формату.
    private var audioEngine = AVAudioEngine()
    private let converter = DSpeechBufferConverter()
    private lazy var meter = DSpeechAudioMeter { [weak self] level in
        DispatchQueue.main.async {
            self?.audioMeter = level
        }
    }

    private var analyzer: SpeechAnalyzer?
    private var transcriber: DictationTranscriber?
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
        locale: Locale,
        contextualStrings: [String]
    ) {
        self.locale = locale
        self.contextualStrings = contextualStrings
        corrector = DSpeechLexiconCorrector(terms: contextualStrings)
    }

    public func start() {
        guard status == .stopped else { return }

        status = .preparing
        text = nil
        audioMeter = 0.0
        finalizedText = AttributedString()

        startTask = Task { [weak self] in
            do {
                try await self?.beginTranscription()
            } catch {
                await self?.stop()
            }
        }
    }

    @discardableResult
    public func stop() async -> String? {
        guard status != .stopped else { return text }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        meter.reset()
        status = .stopped

        startTask?.cancel()
        startTask = nil

        inputBuilder?.finish()
        inputBuilder = nil

        // Даём анализатору доработать хвост аудио и дождаться финального
        // результата: разбор диктовки стартует сразу после `stop()`, а последняя
        // фраза приходит в поток результатов уже после финализации.
        let analyzer = analyzer
        let recognizerTask = recognizerTask
        self.analyzer = nil
        transcriber = nil
        self.recognizerTask = nil

        let finalization = Task {
            try? await analyzer?.finalizeAndFinishThroughEndOfInput()
            await recognizerTask?.value
        }
        // Страховка от зависшей финализации: врач не должен ждать бесконечно.
        let timeout = Task {
            try? await Task.sleep(for: Self.finalizationTimeout)
            guard !Task.isCancelled else { return }
            finalization.cancel()
            recognizerTask?.cancel()
        }
        await finalization.value
        timeout.cancel()

        audioMeter = 0.0
        DSpeechAudioSession.deactivate()

        // Лексику применяем к итоговому тексту, а не к черновикам: на экране
        // подмена терминов по ходу речи только мельтешила бы.
        if let result = text, !result.isEmpty {
            text = corrector.correct(result)
        }

        return text
    }

    private func beginTranscription() async throws {
        let route = try DSpeechAudioSession.activate()

        // Локаль устройства может отличаться регионом от поддерживаемой (или не
        // поддерживаться вовсе) — подбираем ту, что реально знает транскрайбер.
        // В обычном потоке фабрика уже проверила поддержку, так что nil здесь —
        // подстраховка.
        guard let resolvedLocale = await DictationTranscriber.supportedLocale(equivalentTo: locale) else {
            throw DSpeechError.unavailable
        }

        // `.farField` — подсказка «говорят не в упор к микрофону». На гарнитуре
        // она была бы враньём, поэтому ставим её только для встроенного микрофона.
        var contentHints: Set<DictationTranscriber.ContentHint> = []
        switch route {
        case .builtIn:
            contentHints.insert(.farField)
        case .headset:
            break
        }

        let transcriber = DictationTranscriber(
            locale: resolvedLocale,
            contentHints: contentHints,
            transcriptionOptions: [.punctuation],
            reportingOptions: [.volatileResults],
            attributeOptions: []
        )
        self.transcriber = transcriber

        let analyzer = SpeechAnalyzer(modules: [transcriber])
        self.analyzer = analyzer

        // Ради чего всё и затевалось: лексика осмотра доезжает до распознавателя.
        if !contextualStrings.isEmpty {
            let context = AnalysisContext()
            context.contextualStrings[.general] = contextualStrings
            try await analyzer.setContext(context)
        }

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
                await self?.stop()
            }
        }

        try await analyzer.start(inputSequence: inputSequence)

        // Пока грузилась модель, пользователь мог закрыть шторку.
        try Task.checkCancellation()

        audioEngine = AVAudioEngine()
        let (inputNode, recordingFormat) = try prepareInputNode(route: route)
        let converter = converter
        let analyzerFormat = analyzerFormat
        let meter = meter
        inputNode.installTap(onBus: 0, bufferSize: Self.tapBufferSize, format: recordingFormat) { buffer, _ in
            meter.process(buffer)

            guard let analyzerFormat else { return }
            guard let converted = try? converter.convert(buffer, to: analyzerFormat) else { return }
            inputBuilder.yield(AnalyzerInput(buffer: converted))
        }

        audioEngine.prepare()
        try audioEngine.start()

        status = .recording
    }

    /// Готовит входной узел и отдаёт формат, с которым безопасно ставить тап.
    ///
    /// Голосовая обработка перестраивает аудиоблок ввода, и сразу после её
    /// включения узел может отдать формат с нулевой частотой. `installTap` на
    /// таком формате падает по ассерту, поэтому формат проверяем, а при неудаче
    /// откатываем обработку: диктовка без шумоподавления лучше, чем падение.
    private func prepareInputNode(
        route: DSpeechAudioRoute
    ) throws -> (AVAudioInputNode, AVAudioFormat) {
        let inputNode = audioEngine.inputNode

        // Подавление стационарного шума (гул аппарата), эхоподавление,
        // автогромкость. Нужно, когда телефон лежит в стороне, и не нужно на
        // гарнитуре, где микрофон и так у рта.
        try? inputNode.setVoiceProcessingEnabled(route == .builtIn)

        var recordingFormat = inputNode.outputFormat(forBus: 0)
        if !recordingFormat.isValidForCapture, inputNode.isVoiceProcessingEnabled {
            try? inputNode.setVoiceProcessingEnabled(false)
            recordingFormat = inputNode.outputFormat(forBus: 0)
        }
        guard recordingFormat.isValidForCapture else {
            throw DSpeechError.unavailable
        }

        return (inputNode, recordingFormat)
    }

    /// Догружает языковую модель для локали, если её ещё нет на устройстве.
    private func installModelIfNeeded(
        transcriber: DictationTranscriber,
        locale: Locale
    ) async throws {
        let identifier = locale.identifier(.bcp47)
        let installed = await DictationTranscriber.installedLocales
        guard !installed.contains(where: { $0.identifier(.bcp47) == identifier }) else {
            return
        }

        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }
    }
}

/// Приводит буферы микрофона к формату, который ждёт `SpeechAnalyzer`.
private final class DSpeechBufferConverter: @unchecked Sendable {
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

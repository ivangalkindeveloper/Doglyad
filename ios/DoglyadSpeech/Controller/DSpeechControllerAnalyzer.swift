import AVFoundation
import Combine
import Foundation
import Speech

/// Speech recognition on the new `SpeechAnalyzer` stack (iOS 26+).
///
/// It works on-device, without the one-minute limit and with streaming results,
/// which suits long examination dictations better. The language model is downloaded
/// through ``AssetInventory`` when needed — during that time the session stays in
/// the `preparing` state and the microphone is not recording yet.
///
/// `DictationTranscriber` was chosen as the recognition module rather than
/// `SpeechTranscriber`: only it reads `AnalysisContext.contextualStrings`
/// (`SpeechTranscriber` silently ignores them) and only it has the `.farField` hint —
/// and the physician's phone often lies on the scanner rather than near their mouth.
@available(iOS 26.0, *)
@MainActor
public final class DSpeechControllerAnalyzer: DSpeechControllerProtocol {
    /// Tap buffer size. At 48 kHz that is roughly 21 ms of audio.
    private static let tapBufferSize: AVAudioFrameCount = 1024
    /// How long we wait for the analyzer to finish the audio tail after stopping.
    private static let finalizationTimeout: Duration = .seconds(3)

    /// Whether the transcriber supports the given locale. Asynchronous because the
    /// locale list is delivered via `await`. The factory asks this before choosing an
    /// implementation and falls back to `SFSpeechRecognizer` on an uncovered locale.
    public static func isSupported(
        locale: Locale
    ) async -> Bool {
        await DictationTranscriber.supportedLocale(equivalentTo: locale) != nil
    }

    private let locale: Locale
    /// Examination vocabulary: specific terms the recognizer otherwise consistently
    /// mishears.
    private let contextualStrings: [String]
    /// The same vocabulary as post-processing: hints bias recognition, while the
    /// corrector repairs what still came out wrong.
    private let corrector: DSpeechLexiconCorrector
    /// Recreated for every session: voice processing can only be toggled on a stopped
    /// engine, and its state outlives `stop()` — restarting with a different audio
    /// route then leads to an invalid format.
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

    /// Accumulated finalized text: the "draft" chunk of the current phrase is appended
    /// to it so that speech is visible on screen in real time.
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

        // Let the analyzer finish the audio tail and wait for the final result:
        // dictation parsing starts right after `stop()`, and the last phrase arrives
        // in the result stream only after finalization.
        let analyzer = analyzer
        let recognizerTask = recognizerTask
        self.analyzer = nil
        transcriber = nil
        self.recognizerTask = nil

        let finalization = Task {
            try? await analyzer?.finalizeAndFinishThroughEndOfInput()
            await recognizerTask?.value
        }
        // A guard against a stuck finalization: the physician must not wait forever.
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

        // The vocabulary is applied to the final text, not to drafts: swapping terms
        // mid-speech would only make the screen flicker.
        if let result = text, !result.isEmpty {
            text = corrector.correct(result)
        }

        return text
    }

    private func beginTranscription() async throws {
        let route = try DSpeechAudioSession.activate()

        // The device locale may differ by region from a supported one (or not be
        // supported at all) — pick the one the transcriber actually knows.
        // In the normal flow the factory has already checked support, so nil here
        // is a safety net.
        guard let resolvedLocale = await DictationTranscriber.supportedLocale(equivalentTo: locale) else {
            throw DSpeechError.unavailable
        }

        // `.farField` is a hint that the speaker is not right up against the mic. On a
        // headset that would be a lie, so it is set only for the built-in microphone.
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

        // The whole point of the exercise: examination vocabulary reaches the recognizer.
        if !contextualStrings.isEmpty {
            let context = AnalysisContext()
            context.contextualStrings[.general] = contextualStrings
            try await analyzer.setContext(context)
        }

        try await installModelIfNeeded(transcriber: transcriber, locale: resolvedLocale)

        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])

        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputBuilder = inputBuilder

        // Streaming results: final phrases accumulate, the draft one is appended on top.
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

        // The user could have closed the sheet while the model was loading.
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

    /// Prepares the input node and returns a format that is safe to install a tap on.
    ///
    /// Voice processing rebuilds the input audio unit, and right after enabling it the
    /// node may report a format with a zero sample rate. `installTap` on such a format
    /// trips an assert, so the format is validated and, on failure, processing is
    /// rolled back: dictation without noise suppression beats a crash.
    private func prepareInputNode(
        route: DSpeechAudioRoute
    ) throws -> (AVAudioInputNode, AVAudioFormat) {
        let inputNode = audioEngine.inputNode

        // Stationary noise suppression (the scanner's hum), echo cancellation,
        // automatic gain. Needed when the phone lies off to the side, and not needed
        // on a headset where the microphone is at the mouth anyway.
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

    /// Downloads the language model for the locale if it is not on the device yet.
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

/// Converts microphone buffers to the format `SpeechAnalyzer` expects.
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

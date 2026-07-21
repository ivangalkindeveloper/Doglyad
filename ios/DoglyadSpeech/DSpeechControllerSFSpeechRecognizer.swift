import Combine
import Foundation
import Speech

/// Распознавание речи на классическом `SFSpeechRecognizer` (доступно на всех
/// поддерживаемых версиях iOS). По умолчанию использует серверное распознавание,
/// поэтому расставляет пунктуацию и работает как надёжный fallback до iOS 26.
///
/// У одной задачи `SFSpeechRecognizer` есть предел длительности (порядка минуты),
/// после которого сервис сам её финализирует. Чтобы длинную диктовку осмотра не
/// обрывало, аудиодвижок держим запущенным всё время, а распознавательную задачу
/// пересоздаём на каждом финале/ошибке, накапливая готовые куски в один текст.
@MainActor
public final class DSpeechControllerSFSpeechRecognizer: DSpeechControllerProtocol {
    private let audioSession = AVAudioSession.sharedInstance()
    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Признак активной сессии: отличает перезапуск задачи по лимиту (продолжаем)
    /// от остановки пользователем (не перезапускаем).
    private var isRunning = false
    /// Финализированные сегменты предыдущих задач, склеенные в один текст.
    private var finalizedText = ""
    /// Последняя «черновая» расшифровка текущей задачи — на случай, если задачу
    /// оборвёт ошибкой/лимитом без финального результата, чтобы не потерять хвост.
    private var lastPartial = ""

    @Published public var status: DRecordingStatus = .stopped
    @Published public var text: String?
    @Published public var audioMeter: Float = 0.0

    public init(
        locale: Locale
    ) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    public func start() {
        guard !audioEngine.isRunning else { return }

        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Тап и движок живут всю сессию: буферы всегда уходят в текущую задачу,
        // а её пересоздание не рвёт аудиопоток и не теряет слова на стыке.
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateAudioMeter(buffer)
        }

        isRunning = true
        status = .recording
        text = nil
        finalizedText = ""
        lastPartial = ""
        audioMeter = 0.0

        startTask()

        audioEngine.prepare()
        try? audioEngine.start()
    }

    public func stop() {
        isRunning = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        status = .stopped
    }

    /// Создаёт новую распознавательную задачу поверх работающего аудиодвижка.
    private func startTask() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        request.addsPunctuation = true
        request.taskHint = .dictation
        recognitionRequest = request
        lastPartial = ""

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.handleResult(result, error: error, request: request)
            }
        }
    }

    private func handleResult(
        _ result: SFSpeechRecognitionResult?,
        error: (any Error)?,
        request: SFSpeechAudioBufferRecognitionRequest
    ) {
        // Игнорируем отложенные колбэки уже пересозданной или остановленной задачи.
        guard isRunning, request === recognitionRequest else { return }

        if let result {
            let segment = result.bestTranscription.formattedString
            lastPartial = segment
            text = combine(finalizedText, segment)

            if result.isFinal {
                // Лимит длительности или пауза: фиксируем сегмент и катим дальше.
                commitCurrentSegment(segment)
                startTask()
            }
            return
        }

        if error != nil {
            // Задача оборвалась без финала — сохраняем последний черновик и продолжаем.
            commitCurrentSegment(lastPartial)
            startTask()
        }
    }

    /// Дописывает готовый сегмент к накопленному тексту и сбрасывает черновик.
    private func commitCurrentSegment(
        _ segment: String
    ) {
        recognitionRequest?.endAudio()
        recognitionTask = nil
        recognitionRequest = nil

        finalizedText = combine(finalizedText, segment)
        lastPartial = ""
        text = finalizedText
    }

    /// Склеивает два куска через пробел, аккуратно обходя пустые строки.
    private func combine(
        _ base: String,
        _ addition: String
    ) -> String {
        let trimmed = addition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }
        guard !base.isEmpty else { return trimmed }

        return base + " " + trimmed
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

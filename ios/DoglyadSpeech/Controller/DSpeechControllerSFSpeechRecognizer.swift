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
/// Хвост аудио на стыке задач переливает ``DSpeechAudioRelay``.
@MainActor
public final class DSpeechControllerSFSpeechRecognizer: DSpeechControllerProtocol {
    /// Размер буфера тапа. При 48 кГц это примерно 21 мс звука.
    private static let tapBufferSize: AVAudioFrameCount = 1024
    /// Сколько ждём финальный результат после остановки микрофона. Серверное
    /// распознавание может не ответить вовсе (нет сети), и врач не должен
    /// залипать на экране — по истечении берём последний черновик.
    private static let finalizationTimeout: Duration = .seconds(3)

    private let speechRecognizer: SFSpeechRecognizer?
    /// Подсказки распознавателю: специфичная лексика осмотра для текущей локали.
    private let contextualStrings: [String]
    /// Та же лексика, но уже как пост-обработка: подсказки смещают распознавание,
    /// а корректор чинит то, что всё равно услышалось мимо.
    private let corrector: DSpeechLexiconCorrector
    /// Пересоздаётся на каждую сессию: голосовую обработку можно переключать
    /// только на остановленном движке, а её состояние переживает `stop()` и на
    /// повторном старте с другим маршрутом звука приводит к невалидному формату.
    private var audioEngine = AVAudioEngine()
    private let relay = DSpeechAudioRelay()
    private lazy var meter = DSpeechAudioMeter { [weak self] level in
        DispatchQueue.main.async {
            self?.audioMeter = level
        }
    }

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
    /// Ожидание финального результата после `stop()`.
    private var finalizationContinuation: CheckedContinuation<String, Never>?

    @Published public var status: DRecordingStatus = .stopped
    @Published public var text: String?
    @Published public var audioMeter: Float = 0.0

    public init(
        locale: Locale,
        contextualStrings: [String]
    ) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        self.contextualStrings = contextualStrings
        corrector = DSpeechLexiconCorrector(terms: contextualStrings)
    }

    public func start() {
        guard status == .stopped, !audioEngine.isRunning else { return }
        // Без доступного распознавателя запись бессмысленна: движок бы писал,
        // а текста не появлялось бы вовсе.
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }

        status = .preparing
        text = nil
        finalizedText = ""
        lastPartial = ""
        audioMeter = 0.0

        do {
            let route = try DSpeechAudioSession.activate()
            audioEngine = AVAudioEngine()

            // Тап и движок живут всю сессию: буферы всегда уходят в текущую
            // задачу, а её пересоздание не рвёт аудиопоток и не теряет слова
            // на стыке.
            let (inputNode, recordingFormat) = try prepareInputNode(route: route)
            relay.prepare(format: recordingFormat, bufferFrames: Self.tapBufferSize)

            let relay = relay
            let meter = meter
            inputNode.installTap(onBus: 0, bufferSize: Self.tapBufferSize, format: recordingFormat) { buffer, _ in
                relay.append(buffer)
                meter.process(buffer)
            }

            isRunning = true
            startTask()

            audioEngine.prepare()
            try audioEngine.start()

            status = .recording
        } catch {
            teardown()
        }
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

    @discardableResult
    public func stop() async -> String? {
        guard isRunning else { return text }

        isRunning = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        relay.detach()
        meter.reset()
        status = .stopped

        let result = await finalize()

        teardown()
        // Лексику применяем к итоговому тексту, а не к черновикам: на экране
        // подмена терминов по ходу речи только мельтешила бы.
        text = result.isEmpty ? nil : corrector.correct(result)

        return text
    }

    /// Просит сервис доработать оставшееся аудио и дожидается финального
    /// результата. Без этого хвост диктовки терялся бы: `cancel()` выбрасывает
    /// незавершённые результаты, а разбор стартует сразу после остановки.
    private func finalize() async -> String {
        guard let request = recognitionRequest, recognitionTask != nil else {
            return combine(finalizedText, lastPartial)
        }

        request.endAudio()

        let timeout = Task { [weak self] in
            try? await Task.sleep(for: Self.finalizationTimeout)
            guard !Task.isCancelled else { return }
            // Сервис не ответил — отдаём последний черновик, он всё же лучше пустого.
            self?.finishFinalization(with: nil)
        }

        let segment = await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
            finalizationContinuation = continuation
        }
        timeout.cancel()

        return combine(finalizedText, segment)
    }

    /// Завершает ожидание финала. `segment == nil` — таймаут либо ошибка,
    /// в этом случае берём последний черновик текущей задачи.
    private func finishFinalization(
        with segment: String?
    ) {
        guard let continuation = finalizationContinuation else { return }

        finalizationContinuation = nil
        continuation.resume(returning: segment ?? lastPartial)
    }

    private func teardown() {
        isRunning = false
        audioEngine.stop()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        relay.reset()
        audioMeter = 0.0
        status = .stopped
        DSpeechAudioSession.deactivate()
    }

    /// Создаёт новую распознавательную задачу поверх работающего аудиодвижка.
    private func startTask() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        request.addsPunctuation = true
        request.taskHint = .dictation
        request.contextualStrings = contextualStrings
        recognitionRequest = request
        lastPartial = ""

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                self?.handleResult(result, error: error, request: request)
            }
        }

        // Подключаем последним: `attach` сразу переливает в запрос хвост
        // предыдущей задачи, и делать это надо по уже готовому колбэку.
        relay.attach(request)
    }

    private func handleResult(
        _ result: SFSpeechRecognitionResult?,
        error: (any Error)?,
        request: SFSpeechAudioBufferRecognitionRequest
    ) {
        // Игнорируем отложенные колбэки уже пересозданной задачи.
        guard request === recognitionRequest else { return }

        if let result {
            let segment = result.bestTranscription.formattedString
            lastPartial = segment
            if isRunning {
                text = combine(finalizedText, segment)
            }
            guard result.isFinal else { return }

            guard isRunning else {
                finishFinalization(with: segment)
                return
            }
            // Лимит длительности или пауза: фиксируем сегмент и катим дальше.
            commitCurrentSegment(segment)
            startTask()
            return
        }

        guard error != nil else { return }

        guard isRunning else {
            finishFinalization(with: nil)
            return
        }
        // Задача оборвалась без финала — сохраняем последний черновик и продолжаем.
        commitCurrentSegment(lastPartial)
        startTask()
    }

    /// Дописывает готовый сегмент к накопленному тексту и сбрасывает черновик.
    private func commitCurrentSegment(
        _ segment: String
    ) {
        relay.detach()
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
}

import Combine
import DoglyadNeuralModel
import DoglyadSpeech
import DoglyadUI
import SwiftUI

@MainActor
final class ScanSpeechViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: ScanSpeechBottomSheetArguments

    // Реализацию контроллера выбирает фабрика по доступности на системе и
    // поддержке локали, поэтому держим его экзистенциалом. `NestedObservableObject`
    // требует конкретный тип, так что переиздаём изменения вручную через
    // `objectWillChange`.
    //
    // Подбор лучшей реализации асинхронный (поддержка локали в `SpeechTranscriber`
    // читается через `await`), поэтому стартуем с синхронного `SFSpeechRecognizer`
    // и, если система/локаль позволяют, апгрейдимся до `SpeechAnalyzer`.
    private(set) var speechController: any DSpeechControllerProtocol
    private var speechCancellable: AnyCancellable?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: ScanSpeechBottomSheetArguments
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        let contextualStrings = container.getContextualStrings(for: Locale.current)
        speechController = DSpeechFactory.makeDefault(
            locale: Locale.current,
            contextualStrings: contextualStrings
        )
        super.init()
        observeSpeechController()

        Task { [weak self] in
            let controller = await DSpeechFactory.make(
                locale: Locale.current,
                contextualStrings: contextualStrings
            )
            guard let self else { return }
            // Не подменяем во время записи и только если реализация действительно
            // сменилась (иначе фабрика вернула тот же `SFSpeechRecognizer`).
            guard self.speechController.status == .stopped,
                  type(of: controller) != type(of: self.speechController) else { return }

            self.objectWillChange.send()
            self.speechController = controller
            self.observeSpeechController()
        }
    }

    private func observeSpeechController() {
        speechCancellable = speechController.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    @Published var isLoading = false
    let columns = [GridItem(.adaptive(minimum: 100))]

    func onTapBack() {
        router.dismissSheet()
    }

    var speechIcon: ImageResource {
        switch speechController.status {
        case .preparing,
             .recording:
            return .check
        case .stopped:
            return .play
        @unknown default:
            fatalError()
        }
    }

    /// Крутилка на кнопке: и пока поднимается сессия распознавания, и пока идёт
    /// разбор диктовки — в обоих случаях нажимать нечего.
    var isSpeechButtonLoading: Bool {
        guard !isLoading else { return true }

        switch speechController.status {
        case .preparing:
            return true
        case .recording,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    var isAudioMeterVisible: Bool {
        switch speechController.status {
        case .recording:
            return true
        case .preparing,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    /// Пока сессия поднимается (на новом стеке речи может догружаться языковая
    /// модель), микрофон ещё не пишет — просим врача подождать, а не диктовать.
    var isPreparingDescriptionVisible: Bool {
        switch speechController.status {
        case .preparing:
            return true
        case .recording,
             .stopped:
            return false
        @unknown default:
            fatalError()
        }
    }

    var speechText: String? {
        isAudioMeterVisible ? speechController.text : nil
    }

    /// Отдельный флаг под анимацию появления расшифровки. Привязывать анимацию
    /// к самой строке нельзя: черновые результаты приходят несколько раз в
    /// секунду, и вся шторка переигрывала бы анимацию на каждое слово.
    var isSpeechTextVisible: Bool {
        speechText != nil
    }

    var audioMeterLevel: Float {
        speechController.audioMeter
    }

    func onTapSpeech() {
        guard !isLoading else { return }

        switch speechController.status {
        case .preparing:
            // Сессия ещё поднимается — останавливать нечего.
            return
        case .recording:
            onStopSpeech()
        case .stopped:
            speechController.start()
            // Модель разбора весит сотни мегабайт и грузится лениво. Пока врач
            // диктует, успеваем поднять и прогреть её в фоне — иначе он ждёт
            // загрузку уже после того, как закончил говорить.
            container.examinationNeuralModelFactory?.prewarm()
        @unknown default:
            fatalError()
        }
    }

    private func onStopSpeech() {
        isLoading = true

        Task { [weak self] in
            guard let self else { return }
            // Хвост диктовки распознаётся асинхронно уже после остановки
            // микрофона, поэтому итоговый текст берём из `stop()`, а не из
            // `text` сразу после него — иначе последняя фраза теряется.
            let speech = await self.speechController.stop()

            guard let speech, !speech.isEmpty,
                  self.container.examinationNeuralModelFactory != nil
            else {
                self.isLoading = false
                return
            }

            self.onParseSpeech(speech: speech)
        }
    }

    private func onParseSpeech(
        speech: String
    ) {
        guard let factory = container.examinationNeuralModelFactory else { return }

        handle {
            // Первый разбор дополнительно ждёт загрузку модели — она ленивая.
            try await factory.model().parseSpeech(
                speech: speech
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { response in
            self.arguments.onComplete?(response)
            self.router.dismissSheet()
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }
}

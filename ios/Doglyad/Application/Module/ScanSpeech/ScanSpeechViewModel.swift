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
        case .recording:
            return .check
        case .stopped:
            return .play
        @unknown default:
            fatalError()
        }
    }

    func onTapSpeech() {
        guard !isLoading else { return }

        switch speechController.status {
        case .recording:
            onStopSpeech()
        case .stopped:
            speechController.start()
        @unknown default:
            fatalError()
        }
    }

    private func onStopSpeech() {
        speechController.stop()
        guard let factory = container.examinationNeuralModelFactory else { return }
        guard let speech = speechController.text else { return }

        isLoading = true
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

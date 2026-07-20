import DoglyadNeuralModel
import DoglyadSpeech
import DoglyadUI
import NestedObservableObject
import SwiftUI

@MainActor
final class ScanSpeechViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: ScanSpeechBottomSheetArguments

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
    }

    @NestedObservableObject var speechController = DSpeechController(
        locale: Locale.current
    )
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
        }
    }

    func onTapSpeech() {
        guard !isLoading else { return }

        switch speechController.status {
        case .recording:
            onStopSpeech()
        case .stopped:
            speechController.start()
        }
    }

    private func onStopSpeech() {
        guard let examinationNeuralModel = container.examinationNeuralModel else { return }

        // Финальный фрагмент распознавания приходит при остановке движка,
        // поэтому текст забираем уже после stop().
        speechController.stop()
        guard let speech = speechController.text else { return }

        isLoading = true
        handle {
            try await examinationNeuralModel.parseExaminationSpeech(
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

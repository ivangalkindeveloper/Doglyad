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
        guard let provider = container.examinationNeuralModelProvider else { return }
        guard let speech = speechController.text else { return }

        isLoading = true
        handle {
            // Первый разбор дополнительно ждёт загрузку модели — она ленивая.
            try await provider.model().parseSpeech(
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

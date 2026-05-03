import DoglyadNeuralModel
import DoglyadSpeech
import NestedObservableObject
import SwiftUI

@MainActor
final class ScanSpeechViewModel: DViewModel {
    private let container: DependencyContainer
    private let router: DRouter
    private let arguments: ScanSpeechBottomSheetArguments

    init(
        container: DependencyContainer,
        router: DRouter,
        arguments: ScanSpeechBottomSheetArguments
    ) {
        self.container = container
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
        speechController.isRecording ? .check : .play
    }

    func onTapSpeech() {
        guard !isLoading else { return }

        if speechController.isRecording {
            guard let examinationNeuralModel = container.examinationNeuralModel else { return }
            guard let speech = speechController.text else { return }

            speechController.stop()
            Task {
                self.isLoading = true
                let response = try await examinationNeuralModel.parseExaminationSpeech(
                    locale: Locale.current,
                    speech: speech
                )
                self.isLoading = false
                self.arguments.onComplete?(response)
                self.router.dismissSheet()
            }
        } else {
            speechController.start()
        }
    }
}

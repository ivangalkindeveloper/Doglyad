import SwiftUI
import DoglyadSpeech
import DoglyadNeuralModel
import NestedObservableObject

@MainActor
final class SpeechViewModel: ObservableObject {
    private let researchNeuralModel: DResearchNeuralModelProtocol?
    private let router: DRouter
    private let arguments: SpeechBottomSheetArguments
    
    init(
        researchNeuralModel: DResearchNeuralModelProtocol?,
        router: DRouter,
        arguments: SpeechBottomSheetArguments
    ) {
        self.researchNeuralModel = researchNeuralModel
        self.router = router
        self.arguments = arguments
    }
    
    @NestedObservableObject var speechController = DSpeechController(
        locale: Locale.current
    )
    @Published var isLoading = false
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    func onTapBack() -> Void {
        router.dismissSheet()
    }
    
    var speechIcon: ImageResource {
        speechController.isRecording ? .check : .play
    }
    
    func onTapSpeech() -> Void {
        guard !isLoading else { return }
        
        if speechController.isRecording {
            guard let researchNeuralModel = self.researchNeuralModel else { return }
            guard let speech = speechController.text else { return }
            
            speechController.stop()
            Task {
                isLoading = true
                let response = try await researchNeuralModel.parseResearchSpeech(
                    locale: Locale.current,
                    speech: speech
                )
                isLoading = false
                arguments.onComplete?(response)
                router.dismissSheet()
            }
        } else {
            speechController.start()
        }
    }
}


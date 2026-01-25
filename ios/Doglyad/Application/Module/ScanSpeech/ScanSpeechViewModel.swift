import SwiftUI
import DoglyadSpeech
import DoglyadNeuralModel
import NestedObservableObject

@MainActor
final class ScanSpeechViewModel: ObservableObject {
    private let researchNeuralModel: DResearchNeuralModelProtocol?
    private let router: DRouter
    private let arguments: ScanSpeechBottomSheetArguments
    
    init(
        researchNeuralModel: DResearchNeuralModelProtocol?,
        router: DRouter,
        arguments: ScanSpeechBottomSheetArguments
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
        self.router.dismissSheet()
    }
    
    var speechIcon: ImageResource {
        self.speechController.isRecording ? .check : .play
    }
    
    func onTapSpeech() -> Void {
        guard !self.isLoading else { return }
        
        if speechController.isRecording {
            guard let researchNeuralModel = self.researchNeuralModel else { return }
            guard let speech = self.speechController.text else { return }
            
            speechController.stop()
            Task {
                self.isLoading = true
                let response = try await researchNeuralModel.parseResearchSpeech(
                    locale: Locale.current,
                    speech: speech
                )
                self.isLoading = false
                self.arguments.onComplete?(response)
                self.router.dismissSheet()
            }
        } else {
            self.speechController.start()
        }
    }
}


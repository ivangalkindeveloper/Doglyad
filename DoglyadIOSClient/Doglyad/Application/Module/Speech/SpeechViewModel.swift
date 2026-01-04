import SwiftUI
import DoglyadSpeech
import DoglyadML
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
    
    func onTapBack() -> Void {
        router.dismissSheet()
    }
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    let speechKeys: [LocalizedStringResource] = [
        .scanPatientNameLabel,
        .scanPatientGenderLabel,
        .scanPatientDateOfBirthLabel,
        .scanPatientHeightCMLabel,
        .scanPatientWeightKGLabel,
        .scanPatientComplaintLabel,
        .scanResearchDescriptionLabel,
        .scanAdditionalDataLabel
    ]
    
    var speechIcon: ImageResource {
        speechController.isRecording ? .check : .play
    }
    
    func onTapSpeech() -> Void {
        speechController.isRecording ? onTapStop() : onTapStart()
    }
    
    private func onTapStart() -> Void {
        speechController.start()
    }
    
    private func onTapStop() -> Void {
        speechController.stop()
        guard let researchNeuralModel = self.researchNeuralModel else {
            return
        }
        guard let text = speechController.text else {
            return
        }
        
        Task {
            isLoading = true
            let response = try await researchNeuralModel.parseResearchSpeech(
                locale: Locale.current,
                text: text
            )
            isLoading = false
            arguments.onComplete?(response)
            router.dismissSheet()
        }
    }
}


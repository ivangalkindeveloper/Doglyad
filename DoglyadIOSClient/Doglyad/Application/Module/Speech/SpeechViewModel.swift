import SwiftUI
import DoglyadSpeech
import DoglyadML

@MainActor
final class SpeechViewModel: ObservableObject {
    private let researchNeuralModel: DResearchNeuralModelProtocol
    private let router: DRouter
    private let arguments: SpeechBottomSheetArguments
    
    init(
        researchNeuralModel: DResearchNeuralModelProtocol,
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
        guard let text = speechController.text else {
            return
        }
        Task {
            let response = try await researchNeuralModel.parseResearchSpeech(
                locale: Locale.current,
                text: text
            )
//            guard let answer = try? JSONDecoder().decode(PatientResearchNeuralModelResponse.self, from: response.data(using: .utf8)!) else {
//                return
//            }
//            arguments.completion(text)
//            router.dismissSheet()
        }
    }
}


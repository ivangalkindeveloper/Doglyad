import SwiftUI
import DoglyadSpeech

@MainActor
final class SpeechViewModel: ObservableObject {
    private let router: DRouter
    private let arguments: SpeechBottomSheetArguments
    
    init(
        router: DRouter,
        arguments: SpeechBottomSheetArguments
    ) {
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
        .scanPatientName,
        .scanGenderLabel,
        .scanDateOfBirthLabel,
        .scanResearchDescription,
        .scanPatientComplaint,
        .scanAdditionalMedicalData
    ]
    
    var speechIcon: ImageResource {
        speechController.isRecording ? .pause : .play
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
        arguments.completion(text)
        router.dismissSheet()
    }
}


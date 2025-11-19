import SwiftUI
import DoglyadSpeech

@MainActor
final class SpeechViewModel: ObservableObject {
    private var router: DRouter
    
    init(
        router: DRouter
    ) {
        self.router = router
    }
    
    @NestedObservableObject var speechController = DSpeechController(
        locale: Locale.current
    )
    
    func onTapBack() -> Void {
        router.dismissSheet()
    }
    
    let columns = [GridItem(.flexible())]
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
        speechController.start(completion: {
            value in
            print(value)
        } )
    }
    
    private func onTapStop() -> Void {
        speechController.stop()
    }
}


import Foundation
import SwiftUI
import Router
import BottomSheet
import DoglyadUI
import DoglyadCamera

final class ScanViewModel: ObservableObject {
    static let photoMaxCount: Int = 10
    
    private var diagnosticRepository: DiagnosticsRepositoryProtocol?
    private var router: DRouter?
    
    func initialize(
        container: DependencyContainer,
        router: DRouter
    ) -> Void {
        self.diagnosticRepository = container.diagnosticsRepository
        self.router = router
        if let storedResearchType = diagnosticRepository?.getSelectedResearchType() {
            self.researchType = storedResearchType
        }
    }
    
    @Published var researchType = ResearchType.default
    @Published var photos: [ScanPhoto] = []
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    @NestedObservableObject var patientNameController = DInputController(initialText: "Пациент№0")
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @NestedObservableObject var patientComplaintController = DInputController()
    
    func unfocus() -> Void {
        patientNameController.unfocus()
        patientComplaintController.unfocus()
    }
    
    func onPressedHistory() -> Void {
        router?.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onPressedResearchType() {
        router?.push(
            route: RouteSheet(
                type: .selectResearchType,
                arguments: SelectResearchTypeScreenArguments(
                    onSelected: { [weak self] researchType in
                        guard let self = self else { return }
                        guard self.researchType != researchType else { return }
                        self.researchType = researchType
                        self.diagnosticRepository?.setSelectedResearchType(
                            type: researchType
                        )
                    }
                )
            )
        )
    }
    
    var captureIcon: ImageResource {
        photos.count == ScanViewModel.photoMaxCount ? .down : .camera
    }
    
    func onPressedCapture() -> Void {
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }
                photos.append(
                    ScanPhoto(image: image)
                )
                if photos.count == ScanViewModel.photoMaxCount {
                    sheetController.setTop()
                }
            }
        )
    }
    
    func determineOpeningSheet() -> Void {
        if photos.isEmpty {
            return sheetController.setHidden()
        }
        
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        sheetController.setBottom()
    }

    func onPressedDeletePhoto(
        photo: ScanPhoto
    ) -> Void {
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func onPressedPatientNameSpeech() -> Void {}
    
    func onPressedPatientGender(
        value: PatientGender
    ) -> Void {
        guard patientGender != value else { return }
        patientGender = value
    }
    
    func onPressedPatientAge() -> Void {}
    
    func onPressedPatientComplaintSpeech() -> Void {}
    
    func onPressedScan() -> Void {}
}

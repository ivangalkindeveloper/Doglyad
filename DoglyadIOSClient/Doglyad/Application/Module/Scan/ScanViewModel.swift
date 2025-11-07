import Foundation
import SwiftUI
import Router
import BottomSheet
import DoglyadUI
import DoglyadCamera

@MainActor
final class ScanViewModel: ObservableObject {
    static let photoMaxCount: Int = 6
    
    private var diagnosticRepository: DiagnosticsRepositoryProtocol?
    private var router: DRouter?
    private var isInitialized: Bool = false
    
    @Published var researchType = ResearchType.default
    @Published var photos: [ScanPhoto] = []
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    @NestedObservableObject var patientNameController = DTextFieldController(initialText: "Пациент#0")
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @NestedObservableObject var patientComplaintController = DTextFieldController()
    
    var isPhotoFilling: Bool {
        photos.count == ScanViewModel.photoMaxCount
    }
    
    var isCaptureAvailable: Bool {
        cameraController.isRunning && !isPhotoFilling
    }
    
    func onAppear(
        container: DependencyContainer,
        router: DRouter
    ) -> Void {
        if isInitialized { return }
        self.diagnosticRepository = container.diagnosticsRepository
        self.router = router
        if let storedResearchType = diagnosticRepository?.getSelectedResearchType() {
            self.researchType = storedResearchType
        }
        cameraController.startSession()
        isInitialized = true
    }
    
    func onDisappear() -> Void {
        cameraController.stopSession()
    }
    
    func unfocus() -> Void {
        patientNameController.unfocus()
        patientComplaintController.unfocus()
    }
    
    func onChangePhotosForSheet() -> Void {
        if photos.isEmpty {
            return sheetController.setHidden()
        }
        
        if !photos.isEmpty && sheetController.isHidden {
            sheetController.setBottom()
        }
        
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
    }
    
    func onChangeSheetForCamera() -> Void {
        if sheetController.isTop {
            cameraController.stopSession()
        }
    }
    
    func onPressedHistory() -> Void {
        router?.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onPressedResearchType() -> Void {
        router?.push(
            route: RouteSheet(
                type: .selectResearchType,
                arguments: SelectResearchTypeArguments(
                    currentValue: self.researchType,
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
    
    func onPressedPatientDateOfBirth() -> Void {
        router?.push(
            route: RouteSheet(
                type: .selectDateOfBirth,
                arguments: SelectDateOfBirthArguments(
                    currentValue: self.patientDateOfBirth,
                    onSelected: { [weak self] date in
                        guard let self = self else { return }
                        guard self.patientDateOfBirth != date else { return }
                        self.patientDateOfBirth = date
                    }
                )
            )
        )
    }
    
    func onPressedPatientComplaintSpeech() -> Void {}
    
    func onPressedScan() -> Void {}
}

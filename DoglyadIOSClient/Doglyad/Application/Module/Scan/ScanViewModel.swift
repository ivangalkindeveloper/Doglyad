import Foundation
import SwiftUI
import Router
import BottomSheet
import DoglyadUI
import DoglyadCamera

@MainActor
final class ScanViewModel: ObservableObject {
    static let photoMaxCount: Int = 6
    
    private var diagnosticRepository: DiagnosticsRepositoryProtocol
    private var router: DRouter
    
    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        cameraController.startSession()
    }
    
    @Published var researchType = ResearchType.default
    @Published var photos: [ResearchScanPhoto] = []
    //
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    //
    @NestedObservableObject var patientNameController = DTextFieldController(initialText: "Пациент#0")
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    //
    @NestedObservableObject var researchDataController = DTextFieldController()
    //
    @NestedObservableObject var patientComplaintController = DTextFieldController()
    @NestedObservableObject var additionalMedicalDataController = DTextFieldController()
    
    var isPhotoFilling: Bool {
        photos.count == ScanViewModel.photoMaxCount
    }
    
    var isCaptureAvailable: Bool {
        cameraController.isRunning && !isPhotoFilling
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
        if isPhotoFilling {
            return sheetController.setTop()
        }
    }
    
    func onChangeSheetForCamera() -> Void {
        if sheetController.isTop {
            cameraController.stopSession()
        }
    }
    
    func onTapHistory() -> Void {
        router.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onTapResearchType() -> Void {
        router.push(
            route: RouteSheet(
                type: .selectResearchType,
                arguments: SelectResearchTypeArguments(
                    currentValue: self.researchType,
                    onSelected: { [weak self] researchType in
                        guard let self = self else { return }
                        guard self.researchType != researchType else { return }
                        self.researchType = researchType
                        self.diagnosticRepository.setSelectedResearchType(
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
    
    func onTapCapture() -> Void {
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }
                photos.append(
                    ResearchScanPhoto(image: image)
                )
                if photos.count == ScanViewModel.photoMaxCount {
                    sheetController.setTop()
                }
            }
        )
    }

    func onTapDeletePhoto(
        photo: ResearchScanPhoto
    ) -> Void {
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func onTapPatientGender(
        value: PatientGender
    ) -> Void {
        guard patientGender != value else { return }
        patientGender = value
    }
    
    func onTapPatientDateOfBirth() -> Void {
        router.push(
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
    
    func onTapSpeech() -> Void {
        router.push(
            route: RouteSheet(
                type: .speech,
                arguments: SpeechBottomSheetArguments(
                    completion: { value in }
                )
            )
        )
    }
    
    func onTapScan() -> Void {}
}

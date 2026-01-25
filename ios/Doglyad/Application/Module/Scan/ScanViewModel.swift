import BottomSheet
import DoglyadCamera
import DoglyadUI
import Foundation
import NestedObservableObject
import Router
import SwiftUI

@MainActor
final class ScanViewModel: ObservableObject {
    static let photoMaxCount: Int = 6
    
    private let permissionManager: PermissionManagerProtocol
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter
    
    init(
        permissionManager: PermissionManagerProtocol,
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.permissionManager = permissionManager
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
    @NestedObservableObject var patientHeightCMController = DTextFieldController()
    @NestedObservableObject var patientWeightKGController = DTextFieldController()
    @NestedObservableObject var patientComplaintController = DTextFieldController()
    @NestedObservableObject var researchDescriptionController = DTextFieldController()
    @NestedObservableObject var additionalDataController = DTextFieldController()
    
    var isPhotoFilling: Bool {
        photos.count == ScanViewModel.photoMaxCount
    }
    
    var isCaptureAvailable: Bool {
        cameraController.isRunning && !isPhotoFilling
    }
    
    func onDisappear() {
        cameraController.stopSession()
    }
    
    func unfocus() {
        patientNameController.unfocus()
        patientHeightCMController.unfocus()
        patientWeightKGController.unfocus()
        patientComplaintController.unfocus()
        researchDescriptionController.unfocus()
        additionalDataController.unfocus()
    }
    
    func onChangePhotosForSheet() {
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
    
    func onChangeSheetForCamera() {
        if sheetController.isTop {
            cameraController.stopSession()
        }
    }
    
    func onTapHistory() {
        router.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onTapResearchType() {
        router.push(
            route: RouteSheet(
                type: .selectResearchType,
                arguments: SelectResearchTypeArguments(
                    currentValue: researchType,
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
    
    func onTapCapture() {
        if photos.count == ScanViewModel.photoMaxCount {
            return sheetController.setTop()
        }
        
        cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }
                
                photos.append(ResearchScanPhoto(image: image))
                if photos.count == ScanViewModel.photoMaxCount {
                    sheetController.setTop()
                }
            }
        )
    }

    func onTapDeletePhoto(
        photo: ResearchScanPhoto
    ) {
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func onTapPatientGender(
        value: PatientGender
    ) {
        guard patientGender != value else { return }
        
        patientGender = value
    }
    
    func onTapPatientDateOfBirth() {
        router.push(
            route: RouteSheet(
                type: .selectDateOfBirth,
                arguments: SelectDateOfBirthArguments(
                    currentValue: patientDateOfBirth,
                    onSelected: { [weak self] date in
                        guard let self = self else { return }
                        guard self.patientDateOfBirth != date else { return }
                        
                        self.patientDateOfBirth = date
                    }
                )
            )
        )
    }
    
    func onTapSpeech() {
        Task {
            guard await permissionManager.isGranted(.speech) else { return }
            
            router.push(
                route: RouteSheet(
                    type: .speech,
                    arguments: SpeechBottomSheetArguments(
                        onComplete: { [weak self] response in
                            guard let self = self else { return }
                            
                            if let patientName = response.patientName {
                                self.patientNameController.text = patientName
                            }
                            if let patientGender = PatientGender.fromResearchNeuralModelResponse(response.patientGender) {
                                self.patientGender = patientGender
                            }
                            if let patientDateOfBirth = response.patientDateOfBirth {
                                self.patientDateOfBirth = patientDateOfBirth
                            }
                            if let patientHeightCM = response.patientHeightCM {
                                self.patientHeightCMController.text = "\(patientHeightCM)"
                            }
                            if let patientWeightKG = response.patientWeightKG {
                                self.patientWeightKGController.text = "\(patientWeightKG)"
                            }
                            if let patientComplaint = response.patientComplaint {
                                self.patientComplaintController.text = patientComplaint
                            }
                            if let researchDescription = response.researchDescription {
                                self.researchDescriptionController.text = researchDescription
                            }
                            if let additionalData = response.additionalData {
                                self.additionalDataController.text = additionalData
                            }
                        }
                    )
                )
            )
        }
    }
    
    func onTapScan() {}
}

import BottomSheet
import DoglyadCamera
import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import NestedObservableObject
import Router
import SwiftUI

@MainActor
final class ScanViewModel: Handler<DHttpApiError, DHttpConnectionError>, ObservableObject {
    static let photoMaxCount: Int = 6
    private static let defaultPatientHeightCM: Double = 180
    private static let defaultPatientWeightKG: Double = 60
    
    private let permissionManager: PermissionManagerProtocol
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let messanger: DMessager
    private let router: DRouter
    
    init(
        permissionManager: PermissionManagerProtocol,
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        messanger: DMessager,
        router: DRouter
    ) {
        self.permissionManager = permissionManager
        self.diagnosticRepository = diagnosticRepository
        self.messanger = messanger
        self.router = router
        super.init()
        self.onInit()
    }
    
    @Published var researchType = ResearchType.default
    @Published var photos: [ResearchScanPhoto] = []
    //
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    //
    @NestedObservableObject var patientNameController = DTextFieldController()
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    @NestedObservableObject var patientHeightCMController = DTextFieldController()
    @NestedObservableObject var patientWeightKGController = DTextFieldController()
    @NestedObservableObject var patientComplaintController = DTextFieldController()
    @NestedObservableObject var researchDescriptionController = DTextFieldController()
    @NestedObservableObject var additionalDataController = DTextFieldController()
    //
    @Published var isLoading = false
    
    private func onInit() {
        self.cameraController.startSession()
        if let selectedResearchType = self.diagnosticRepository.getSelectedResearchType() {
            self.researchType = selectedResearchType
        }
        
        let patientCount = self.diagnosticRepository.getConclusions().count
        self.patientNameController.text = String(localized: .scanPatientDefaultNameLabel(count: patientCount))
    }
    
    var isPhotoFilling: Bool {
        self.photos.count == Self.photoMaxCount
    }
    
    var isCaptureAvailable: Bool {
        self.cameraController.isRunning && !self.isPhotoFilling
    }
    
    func onDisappear() {
        self.cameraController.stopSession()
    }
    
    func unfocus() {
        self.patientNameController.unfocus()
        self.patientHeightCMController.unfocus()
        self.patientWeightKGController.unfocus()
        self.patientComplaintController.unfocus()
        self.researchDescriptionController.unfocus()
        self.additionalDataController.unfocus()
    }
    
    func onChangePhotosForSheet() {
        if self.photos.isEmpty {
            return self.sheetController.setHidden()
        }
        if !self.photos.isEmpty && self.sheetController.isHidden {
            self.sheetController.setBottom()
        }
        if self.isPhotoFilling {
            return self.sheetController.setTop()
        }
    }
    
    func onChangeSheetForCamera() {
        if self.sheetController.isTop {
            self.cameraController.stopSession()
        }
    }
    
    func onTapHistory() {
        self.router.push(
            route: RouteScreen(
                type: .history
            )
        )
    }
    
    func onTapResearchType() {
        self.router.push(
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
        self.photos.count == ScanViewModel.photoMaxCount ? .down : .camera
    }
    
    func onTapCapture() {
        if self.photos.count == ScanViewModel.photoMaxCount {
            return self.sheetController.setTop()
        }
        
        self.cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }
                
                self.photos.append(ResearchScanPhoto(image: image))
                if self.photos.count == ScanViewModel.photoMaxCount {
                    self.sheetController.setTop()
                }
            }
        )
    }

    func onTapDeletePhoto(
        photo: ResearchScanPhoto
    ) {
        self.photos.remove(at: self.photos.firstIndex(of: photo)!)
    }
    
    func onTapPatientGender(
        value: PatientGender
    ) {
        guard self.patientGender != value else { return }
        
        self.patientGender = value
    }
    
    func onTapPatientDateOfBirth() {
        self.router.push(
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
    
    func onTapSpeech() {
        Task {
            guard await self.permissionManager.isGranted(.speech) else {
                return self.router.push(
                    route: RouteSheet(
                        type: .permissionSpeech,
                    )
                )
            }
            
            self.router.push(
                route: RouteSheet(
                    type: .scanSpeech,
                    arguments: ScanSpeechBottomSheetArguments(
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
    
    func onTapScan() {
        let data = ResearchData(
            researchType: self.researchType,
            photos: self.photos,
            patientName: self.patientNameController.text,
            patientGender: self.patientGender,
            patientDateOfBirth: self.patientDateOfBirth,
            patientHeight: Double(self.patientHeightCMController.text) ?? Self.defaultPatientHeightCM,
            patientWeight: Double(self.patientWeightKGController.text) ?? Self.defaultPatientWeightKG,
            patientComplaint: self.patientComplaintController.text,
            researchDescription: self.researchDescriptionController.text,
            additionalData: self.additionalDataController.text
        )
        self.handle({
            self.isLoading = true
            return try await self.diagnosticRepository.generateConclusion(
                researchData: data,
                locale: Locale.current
            )
        }, onDefer: {
            self.isLoading = false
        }, onMainSuccess: { modelConclusion in
            let conclusion = ResearchConclusion(
                date: Date(),
                data: data,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: []
            )
            self.diagnosticRepository.setConclusion(
                conclusion: conclusion
            )
            self.router.push(
                route: RouteScreen(
                    type: .conclusion,
                    arguments: ConclusionScreenArguments(
                        conclusion: conclusion
                    )
                )
            )
        }, onUnknownError: { _ in
            self.messanger.showUnknownError()
        })
    }
}

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
    enum Focus: Hashable {
        case patientName
        case patientHeightCM
        case patientWeightKG
        case patientComplaint
        case researchDescription
        case additionalData
    }

    static let photoMaxCount: Int = 6
    private static let defaultPatientDateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
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
        onInit()
    }

    @Published var researchType = ResearchType.default
    @Published var photos: [ResearchScanPhoto] = []
    //
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    @Published var focus: Focus? = nil
    //
    @NestedObservableObject var patientNameController = DTextFieldController(isRequired: true)
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth = defaultPatientDateOfBirth
    @NestedObservableObject var patientHeightCMController = DTextFieldController(isRequired: true)
    @NestedObservableObject var patientWeightKGController = DTextFieldController(isRequired: true)
    @NestedObservableObject var patientComplaintController = DTextFieldController(isRequired: true)
    @NestedObservableObject var researchDescriptionController = DTextFieldController(isRequired: true)
    @NestedObservableObject var additionalDataController = DTextFieldController()
    //
    @Published var isLoading = false

    private func onInit() {
        cameraController.startSession()
        if let selectedResearchType = diagnosticRepository.getSelectedResearchType() {
            researchType = selectedResearchType
        }

        let patientCount = diagnosticRepository.getConclusions().count
        patientNameController.text = String(localized: .scanPatientDefaultNameLabel(count: patientCount))
    }

    var isPhotoFilling: Bool {
        photos.count == Self.photoMaxCount
    }

    var isCaptureAvailable: Bool {
        cameraController.isRunning && !isPhotoFilling
    }

    func unfocus() {
        focus = nil
    }

    func onSubmit() {
        switch focus {
        case .patientName:
            focus = .patientHeightCM
        case .patientHeightCM:
            focus = .patientWeightKG
        case .patientWeightKG:
            focus = .patientComplaint
        case .patientComplaint:
            focus = .researchDescription
        case .researchDescription:
            focus = .additionalData
        case .additionalData, .none:
            focus = nil
        }
    }

    func onDisappear() {
        cameraController.stopSession()
    }

    func onChangePhotosForSheet() {
        if photos.isEmpty {
            return sheetController.setHidden()
        }
        if !photos.isEmpty, sheetController.isHidden {
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

    func onTapSettings() {
        router.push(
            route: RouteScreen(
                type: .settings
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
            guard await self.permissionManager.isGranted(.speech) else {
                return self.router.push(
                    route: RouteSheet(
                        type: .permissionSpeech
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
        let isPatientNameValid = patientNameController.validate()
        let isPatientHeightCMValid = patientHeightCMController.validate()
        let isPatientWeightKGValid = patientWeightKGController.validate()
        let isPatientComplaintValid = patientComplaintController.validate()
        let isResearchDescriptionValid = researchDescriptionController.validate()
        let isAdditionalDataValid = additionalDataController.validate()
        guard !photos.isEmpty,
              isPatientNameValid,
              isPatientHeightCMValid,
              isPatientWeightKGValid,
              isPatientComplaintValid,
              isResearchDescriptionValid,
              isAdditionalDataValid
        else {
            return
        }

        let data = ResearchData(
            researchType: researchType,
            photos: photos,
            patientName: patientNameController.text,
            patientGender: patientGender,
            patientDateOfBirth: patientDateOfBirth,
            patientHeight: Double(patientHeightCMController.text) ?? Self.defaultPatientHeightCM,
            patientWeight: Double(patientWeightKGController.text) ?? Self.defaultPatientWeightKG,
            patientComplaint: patientComplaintController.text,
            researchDescription: researchDescriptionController.text,
            additionalData: additionalDataController.text
        )
        handle {
            self.isLoading = true
            return try await self.diagnosticRepository.generateConclusion(
                researchData: data,
                locale: Locale.current
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { modelConclusion in
            let conclusion = ResearchConclusion(
                date: Date(),
                data: data,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: []
            )

            self.diagnosticRepository.setConclusion(
                conclusion: conclusion
            )

            self.photos.removeAll()
            self.patientNameController.clear()
            self.patientGender = .male
            self.patientDateOfBirth = Self.defaultPatientDateOfBirth
            self.patientHeightCMController.clear()
            self.patientWeightKGController.clear()
            self.patientComplaintController.clear()
            self.researchDescriptionController.clear()
            self.additionalDataController.clear()

            self.router.push(
                route: RouteScreen(
                    type: .conclusion,
                    arguments: ConclusionScreenArguments(
                        conclusion: conclusion
                    )
                )
            )
        } onUnknownError: { _ in
            self.messanger.showUnknownError()
        }
    }
}

import BottomSheet
import DoglyadCamera
import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
@Observable
final class ScanViewModel: Handler<DHttpApiError, DHttpConnectionError> {
    enum Focus: Hashable {
        case patientName
        case patientHeightCM
        case patientWeightKG
        case patientComplaint
        case examinationDescription
        case additionalData
    }

    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        usExaminationType = container.usExaminationTypeDefault
        super.init()
        onInit()
    }

    private var ultrasoundConfig: UltrasoundConfig {
        container.applicationConfig.ultrasound
    }

    var photoMaxCount: Int {
        ultrasoundConfig.scanPhotoMaxNumber
    }

    private var defaultPatientDateOfBirth: Date {
        Calendar.current.date(byAdding: .year, value: -ultrasoundConfig.defaultPatientDateOfBirthGap, to: Date())!
    }

    private var defaultPatientHeightCM: Double {
        ultrasoundConfig.defaultPatientHeightCM
    }

    private var defaultPatientWeightKG: Double {
        ultrasoundConfig.defaultPatientWeightKG
    }

    var usExaminationType: USExaminationType
    var photos: [USExaminationScanPhoto] = []
    var cameraController = DCameraController()
    var sheetController = ScanSheetController()
    //
    var focus: Focus?
    var patientNameController = DTextFieldController(isRequired: true)
    var patientGender = PatientGender.male
    var patientDateOfBirth: Date = .init()
    var patientHeightCMController = DTextFieldController(isRequired: true)
    var patientWeightKGController = DTextFieldController(isRequired: true)
    var patientComplaintController = DTextFieldController(isRequired: true)
    var examinationDescriptionController = DTextFieldController(isRequired: true)
    var additionalDataController = DTextFieldController()
    //
    var isLoading = false

    private func onInit() {
        cameraController.startSession()
        if let usExaminationTypeId = container.ultrasoundConclusionRepository.getSelectedExaminationTypeId(),
           let usExaminationType = container.usExaminationTypesById[usExaminationTypeId]
        {
            self.usExaminationType = usExaminationType
        }
        handle {
            await self.container.ultrasoundConclusionRepository.getConclusions().count
        } onMainSuccess: { patientCount in
            self.patientNameController.text = String(localized: .scanPatientDefaultNameLabel(count: patientCount))
        }
        patientDateOfBirth = defaultPatientDateOfBirth
        patientHeightCMController.text = String(defaultPatientHeightCM)
        patientWeightKGController.text = String(defaultPatientWeightKG)
    }

    var isPhotoFilling: Bool {
        photos.count == photoMaxCount
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
            focus = .examinationDescription
        case .examinationDescription:
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

    func onTapUSExaminationType() {
        router.push(
            route: RouteSheet(
                type: .selectUSExaminationType,
                arguments: SelectUSExaminationTypeArguments(
                    currentValue: usExaminationType,
                    onSelected: { [weak self] usExaminationType in
                        guard let self = self else { return }
                        guard self.usExaminationType != usExaminationType else { return }

                        self.usExaminationType = usExaminationType
                        self.container.ultrasoundConclusionRepository.setSelectedExaminationTypeId(
                            id: usExaminationType.id
                        )
                    }
                )
            )
        )
    }

    var captureIcon: ImageResource {
        photos.count == photoMaxCount ? .down : .camera
    }

    func onTapCapture() {
        if photos.count == photoMaxCount {
            return sheetController.setTop()
        }

        cameraController.takePhoto(
            completion: { [weak self] image in
                guard let self = self else { return }

                self.photos.append(USExaminationScanPhoto(image: image))
                if self.photos.count == self.photoMaxCount {
                    self.sheetController.setTop()
                }
            }
        )
    }

    func onTapDeletePhoto(
        photo: USExaminationScanPhoto
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

    func getTemplate(
        ultrasoundViewModel: UltrasoundViewModel
    ) -> USExaminationTemplate? {
        ultrasoundViewModel.templateIdByUSExaminationTypeId[usExaminationType.id]
    }

    func onTapSelectedTemplate(
        ultrasoundViewModel: UltrasoundViewModel
    ) {
        if let template = getTemplate(ultrasoundViewModel: ultrasoundViewModel) {
            return router.push(
                route: RouteScreen(
                    type: .templateEdit,
                    arguments: TemplateEditScreenArguments(
                        templateId: template.id
                    )
                )
            )
        }

        router.push(
            route: RouteScreen(
                type: .templateList
            )
        )
    }

    func onTapNeuralModelSettings() {
        router.push(
            route: RouteScreen(
                type: .neuralModel
            )
        )
    }

    func onTapFill() {
        patientComplaintController.text = """
        Пациент предъявляет жалобы на периодическое ощущение давления и дискомфорта в передней области шеи, \
        возникающее преимущественно в утренние часы и при физической нагрузке. \
        Отмечает затруднение при глотании твёрдой пищи, появившееся около трёх недель назад. \
        Со слов пациента, в последний месяц наблюдается выраженная общая слабость, \
        повышенная утомляемость и снижение работоспособности во второй половине дня. \
        Эпизодически фиксирует субфебрильную температуру до 37,2 °C. \
        Потери веса не отмечает. Ранее подобных жалоб не предъявлял. \
        Наследственный анамнез по заболеваниям щитовидной железы не отягощён.
        """
        examinationDescriptionController.text = """
        Проведено ультразвуковое исследование щитовидной железы линейным датчиком \
        в стандартных продольных и поперечных проекциях с оценкой обеих долей и перешейка. \
        Правая доля: 52×18×16 мм, объём 7,4 мл. Левая доля: 50×17×15 мм, объём 6,3 мл. \
        Общий объём железы — 13,7 мл, что соответствует верхней границе нормы. \
        Контуры долей ровные, чёткие, капсула не утолщена. \
        Эхогенность паренхимы средняя, структура однородная, без очаговых изменений. \
        Перешеек толщиной 4 мм, без особенностей. \
        Кровоток при цветовом допплеровском картировании симметричный, не усилен. \
        Региональные лимфатические узлы шеи не увеличены, обычной структуры.
        """
        additionalDataController.text = """
        Исследование выполнено на стационарном ультразвуковом аппарате экспертного класса \
        с использованием линейного мультичастотного датчика 7,5–12 МГц. \
        Настройки глубины сканирования и фокусировки оптимизированы \
        для визуализации поверхностно расположенных структур шеи. \
        Качество визуализации хорошее на протяжении всего исследования. \
        Пациент находился в положении лёжа на спине с запрокинутой головой. \
        Архивирование ключевых изображений выполнено в формате DICOM.
        """
    }

    func onTapSpeech() {
        handle {
            await self.container.permissionManager.isGranted(.speech)
        } onMainSuccess: { isGranted in
            if !isGranted {
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
                            if let patientGender = PatientGender.fromUSExaminationNeuralModelResponse(response.patientGender) {
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
                            if let examinationDescription = response.examinationDescription {
                                self.examinationDescriptionController.text = examinationDescription
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

    func onTapScan(ultrasoundViewModel: UltrasoundViewModel) {
        let isPatientNameValid = patientNameController.validate()
        let isPatientHeightCMValid = patientHeightCMController.validate()
        let isPatientWeightKGValid = patientWeightKGController.validate()
        let isPatientComplaintValid = patientComplaintController.validate()
        let isExaminationDescriptionValid = examinationDescriptionController.validate()
        let isAdditionalDataValid = additionalDataController.validate()
        guard !photos.isEmpty,
              isPatientNameValid,
              isPatientHeightCMValid,
              isPatientWeightKGValid,
              isPatientComplaintValid,
              isExaminationDescriptionValid,
              isAdditionalDataValid
        else {
            return
        }

        unfocus()

        if ultrasoundViewModel.availableRequestCount <= 0 {
            return router.push(
                route: RouteSheet(
                    type: .scanRequestLimitExceeded
                )
            )
        }

        let neuralModel = ultrasoundViewModel.neuralModel
        let responseLength = ultrasoundViewModel.responseLength
        let neuralModelSettings = NeuralModelSettings(
            selectedNeuralModelId: neuralModel.id,
            temperature: ultrasoundViewModel.temperature,
            responseLength: responseLength
        )
        let examinationData = USExaminationData(
            usExaminationTypeId: usExaminationType.id,
            photos: photos,
            patientName: patientNameController.text,
            patientGender: patientGender,
            patientDateOfBirth: patientDateOfBirth,
            patientHeight: Double(patientHeightCMController.text) ?? defaultPatientHeightCM,
            patientWeight: Double(patientWeightKGController.text) ?? defaultPatientWeightKG,
            patientComplaint: patientComplaintController.text,
            examinationDescription: examinationDescriptionController.text,
            additionalData: additionalDataController.text
        )
        let template = getTemplate(ultrasoundViewModel: ultrasoundViewModel)

        handle {
            self.isLoading = true

            let request = USExaminationRequest(
                neuralModelSettings: neuralModelSettings,
                examinationData: examinationData,
                template: template?.content
            )
            let modelConclusion = try await self.container.ultrasoundConclusionRepository.generateConclusion(
                locale: Locale.current,
                request: request,
                scanPhotoEncodingOptions: ScanPhotoEncodingOptions(
                    resizeMaxDimension: self.ultrasoundConfig.scanPhotoResizeMaxDimension,
                    compressionQuality: self.ultrasoundConfig.scanPhotoCompressionQuality
                )
            )
            ultrasoundViewModel.incrementRequestCount()
            await self.reset()

            let conclusion = USExaminationConclusion(
                date: Date(),
                neuralModelSettings: neuralModelSettings,
                examinationData: examinationData,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: []
            )
            await self.container.ultrasoundConclusionRepository.setConclusion(
                conclusion: conclusion
            )

            return conclusion
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { conclusion in
            self.router.push(
                route: RouteSheet(
                    type: .recievedConclusion,
                    arguments: RecievedConclusionBottomSheetArguments(
                        conclusion: conclusion
                    )
                )
            )
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }

    private func reset() async {
        sheetController.setHidden()
        photos.removeAll()
        let patientCount = await container.ultrasoundConclusionRepository.getConclusions().count
        patientNameController.text = String(localized: .scanPatientDefaultNameLabel(count: patientCount))
        patientGender = .male
        patientDateOfBirth = defaultPatientDateOfBirth
        patientHeightCMController.text = String(defaultPatientHeightCM)
        patientWeightKGController.text = String(defaultPatientWeightKG)
        patientComplaintController.clear()
        examinationDescriptionController.clear()
        additionalDataController.clear()
    }
}

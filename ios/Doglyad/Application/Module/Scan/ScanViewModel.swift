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
final class ScanViewModel: DViewModel {
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
    private let getTemplateForType: (String) -> USExaminationTemplate?
    private let getFormCompletionViaMicrophoneAvailability: () -> SubscriptionFeatureAvailability
    private let getNeuralModelSettingsAvailability: () -> SubscriptionFeatureAvailability
    private let getNeuralModelSettings: () -> NeuralModelSettings
    private let getNeuralModel: () -> USExaminationNeuralModel
    private let onNeuralModelSelected: (USExaminationNeuralModel) -> Void
    private let refreshSubscriptionStatus: () async -> Void
    private let getIsActive: () -> Bool
    private let getAvailableRequestCount: () -> Int
    private let onIncrementRequestCount: () -> Void

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        getTemplateForType: @escaping (String) -> USExaminationTemplate?,
        refreshSubscriptionStatus: @escaping () async -> Void,
        getIsActive: @escaping () -> Bool,
        getAvailableRequestCount: @escaping () -> Int,
        getFormCompletionViaMicrophoneAvailability: @escaping () -> SubscriptionFeatureAvailability,
        getNeuralModelSettingsAvailability: @escaping () -> SubscriptionFeatureAvailability,
        getNeuralModelSettings: @escaping () -> NeuralModelSettings,
        getNeuralModel: @escaping () -> USExaminationNeuralModel,
        onNeuralModelSelected: @escaping (USExaminationNeuralModel) -> Void,
        onIncrementRequestCount: @escaping () -> Void
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.getTemplateForType = getTemplateForType
        self.refreshSubscriptionStatus = refreshSubscriptionStatus
        self.getIsActive = getIsActive
        self.getAvailableRequestCount = getAvailableRequestCount
        self.getFormCompletionViaMicrophoneAvailability = getFormCompletionViaMicrophoneAvailability
        self.getNeuralModelSettingsAvailability = getNeuralModelSettingsAvailability
        self.getNeuralModelSettings = getNeuralModelSettings
        self.getNeuralModel = getNeuralModel
        self.onNeuralModelSelected = onNeuralModelSelected
        self.onIncrementRequestCount = onIncrementRequestCount
        usExaminationType = container.usExaminationTypeDefault
        super.init()
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

    @Published var usExaminationType: USExaminationType
    @Published var photos: [USExaminationScanPhoto] = []
    @NestedObservableObject var cameraController = DCameraController()
    @NestedObservableObject var sheetController = ScanSheetController()
    //
    @Published var focus: Focus? = nil
    @NestedObservableObject var patientNameController = DTextFieldController(isRequired: true)
    @Published var patientGender = PatientGender.male
    @Published var patientDateOfBirth: Date = .init()
    @NestedObservableObject var patientHeightCMController = DTextFieldController(isRequired: true)
    @NestedObservableObject var patientWeightKGController = DTextFieldController(isRequired: true)
    @NestedObservableObject var patientComplaintController = DTextFieldController(isRequired: true)
    @NestedObservableObject var examinationDescriptionController = DTextFieldController(isRequired: true)
    @NestedObservableObject var additionalDataController = DTextFieldController()
    //
    @Published var isLoading = false

    override func onInit() {
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

                self.onCapture(image)
            }
        )
    }

    private func onCapture(
        _ image: UIImage
    ) {
        guard !isPhotoFilling else { return }

        photos.append(USExaminationScanPhoto(image: image))
        if isPhotoFilling {
            sheetController.setTop()
        }
    }

    func onTapGallery() {
        handle {
            await self.container.permissionManager.isGranted(.photoLibrary)
        } onMainSuccess: { isGranted in
            guard isGranted else {
                return self.router.push(
                    route: RouteSheet(
                        type: .permissionPhotoLibrary
                    )
                )
            }

            self.router.push(
                route: RouteSheet(
                    type: .photoLibraryPicker,
                    arguments: PhotoLibraryPickerArguments(
                        selectionLimit: self.gallerySelectionLimit,
                        onComplete: { [weak self] images in
                            guard let self = self else { return }

                            self.onSelectGalleryImages(images)
                        }
                    )
                )
            )
        }
    }

    private var gallerySelectionLimit: Int {
        max(photoMaxCount - photos.count, 0)
    }

    private func onSelectGalleryImages(
        _ images: [UIImage]
    ) {
        guard !isPhotoFilling else { return }

        let availableCount = photoMaxCount - photos.count
        for image in images.prefix(availableCount) {
            photos.append(USExaminationScanPhoto(image: image))
        }

        if isPhotoFilling {
            sheetController.setTop()
        }
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

    func getTemplate() -> USExaminationTemplate? {
        getTemplateForType(usExaminationType.id)
    }

    func onTapSelectedTemplate() {
        if let template = getTemplate() {
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

    var isNeuralModelSettingsVisible: Bool {
        switch getNeuralModelSettingsAvailability() {
        case .offered, .available:
            return true
        case .unavailable:
            return false
        }
    }

    var isNeuralModelSettingsProBadgeVisible: Bool {
        switch getNeuralModelSettingsAvailability() {
        case .offered:
            return true
        case .available, .unavailable:
            return false
        }
    }

    func onTapNeuralModelSelection() {
        router.push(
            route: RouteSheet(
                type: .selectNeuralModel,
                arguments: SelectNeuralModelArguments(
                    currentValue: getNeuralModel(),
                    onSelected: { [weak self] model in
                        self?.onNeuralModelSelected(model)
                    }
                )
            )
        )
    }

    func onTapNeuralModelSettings() {
        switch getNeuralModelSettingsAvailability() {
        case .available:
            router.push(
                route: RouteScreen(
                    type: .neuralModelSettings
                )
            )
        case .offered:
            router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
        case .unavailable:
            break
        }
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

    var isSpeechButtonVisible: Bool {
        guard container.isUSExaminationNeuralModelAvailable else { return false }

        switch getFormCompletionViaMicrophoneAvailability() {
        case .offered, .available:
            return true
        case .unavailable:
            return false
        }
    }

    var isSpeechButtonProBadgeVisible: Bool {
        switch getFormCompletionViaMicrophoneAvailability() {
        case .offered:
            return true
        case .available, .unavailable:
            return false
        }
    }

    var isSpeechButtonShimmering: Bool {
        switch getFormCompletionViaMicrophoneAvailability() {
        case .available:
            return true
        case .offered, .unavailable:
            return false
        }
    }

    func onTapSpeech() {
        switch getFormCompletionViaMicrophoneAvailability() {
        case .available:
            break
        case .offered, .unavailable:
            return router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
        }
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

    func onTapScan() {
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

        handle {
            await self.refreshSubscriptionStatus()
        } onMainSuccess: { _ in
            guard self.getIsActive() else {
                return self.router.push(
                    route: RouteScreen(
                        type: .subscriptionPaywall
                    )
                )
            }
            guard self.getAvailableRequestCount() > 0 else {
                return self.router.push(
                    route: RouteSheet(
                        type: .requestLimitExceeded,
                        arguments: RequestLimitExceededArguments()
                    )
                )
            }
            self.performScan()
        }
    }

    private func performScan() {
        handle {
            self.isLoading = true

            let neuralModelSettings = self.getNeuralModelSettings()
            let examinationData = USExaminationData(
                usExaminationTypeId: self.usExaminationType.id,
                photos: self.photos,
                patientName: self.patientNameController.text,
                patientGender: self.patientGender,
                patientDateOfBirth: self.patientDateOfBirth,
                patientHeight: Double(self.patientHeightCMController.text) ?? self.defaultPatientHeightCM,
                patientWeight: Double(self.patientWeightKGController.text) ?? self.defaultPatientWeightKG,
                patientComplaint: self.patientComplaintController.text,
                examinationDescription: self.examinationDescriptionController.text,
                additionalData: self.additionalDataController.text
            )
            let template = self.getTemplate()
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
            self.onIncrementRequestCount()
            await self.reset()

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

import Foundation

@MainActor
@Observable
final class UltrasoundViewModel {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container
        let settings = container.ultrasoundModelRepository.getSettings()
        if let id = settings.selectedNeuralModelId,
           let model = container.usExaminationNeuralModelsById[id]
        {
            self.neuralModel = model
        } else {
            self.neuralModel = container.usExaminationNeuralModelDefault
        }
        self.template = settings.template
        self.responseLength = settings.responseLength
        self.selectedTemplateIdByExaminationTypeId = container.templateRepository
            .getSelectedTemplateIdByExaminationType()
        self.availableRequestCount = container.ultrasoundModelRepository.remainingRequestCount(
            limit: container.applicationConfig.ultrasound.requestCountPerDay
        )
    }

    var neuralModel: USExaminationNeuralModel
    var template: String?
    var responseLength: Int?
    var selectedTemplateIdByExaminationTypeId: [String: String]
    var availableRequestCount: Int

    func update(
        neuralModel: USExaminationNeuralModel,
        template: String?,
        responseLength: Int?
    ) {
        self.neuralModel = neuralModel
        self.template = template
        self.responseLength = responseLength
        container.ultrasoundModelRepository.setSettings(settings: neuralModelSettings)
    }

    func incrementRequestCount() {
        container.ultrasoundModelRepository.incrementRequestCount()
        availableRequestCount = container.ultrasoundModelRepository.remainingRequestCount(
            limit: container.applicationConfig.ultrasound.requestCountPerDay
        )
    }

    func saveTemplate(
        _ template: USExaminationTemplate
    ) {
        container.templateRepository.saveTemplate(template)
        container.templateRepository.setSelectedTemplateId(
            template.id,
            forExaminationTypeId: template.usExaminationType.id
        )
        syncTemplates()
    }

    func updateTemplate(
        _ template: USExaminationTemplate
    ) {
        container.templateRepository.saveTemplate(template)
        syncTemplates()
    }

    func deleteTemplate(
        id: String
    ) {
        container.templateRepository.deleteTemplate(id: id)
        syncTemplates()
    }

    private func syncTemplates() {
        selectedTemplateIdByExaminationTypeId = container.templateRepository
            .getSelectedTemplateIdByExaminationType()
    }
}

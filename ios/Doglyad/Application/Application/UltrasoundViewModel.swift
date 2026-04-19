import Foundation

@MainActor
@Observable
final class UltrasoundViewModel {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container

        let ultrasoundModelRepository = container.ultrasoundModelRepository
        if let id = ultrasoundModelRepository.getSelectedModelId(),
           let model = container.usExaminationNeuralModelsById[id]
        {
            neuralModel = model
        } else {
            neuralModel = container.usExaminationNeuralModelDefault
        }

        let ultrasoundConfig = container.applicationConfig.ultrasound
        if let temperature = ultrasoundModelRepository.getTemperature() {
            self.temperature = temperature
        } else {
            temperature = ultrasoundConfig.defaultNeuralModelTemperature
        }
        if let responseLength = ultrasoundModelRepository.getResponseLength() {
            self.responseLength = responseLength
        } else {
            responseLength = ultrasoundConfig.defaultNeuralModelResponseLength
        }

        templateIdByUSExaminationTypeId = container.templateRepository
            .getTemplateIdByUSExaminationType()

        availableRequestCount = container.ultrasoundModelRepository.remainingRequestCount(
            limit: container.applicationConfig.ultrasound.requestCountPerDay
        )
    }

    var neuralModel: USExaminationNeuralModel
    var temperature: Double
    var responseLength: Int
    var templateIdByUSExaminationTypeId: [String: UUID]
    var availableRequestCount: Int

    func saveNeuralModel(
        _ model: USExaminationNeuralModel
    ) {
        neuralModel = model
        container.ultrasoundModelRepository.setSelectedModelId(id: model.id)
    }

    func saveNeuralModelSettings(
        temperature: Double?,
        responseLength: Int?
    ) {
        if let temperature = temperature {
            self.temperature = temperature
            container.ultrasoundModelRepository.setTemperature(temperature)
        }
        if let responseLength = responseLength {
            self.responseLength = responseLength
            container.ultrasoundModelRepository.setResponseLength(responseLength)
        }
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
        container.templateRepository.saveTemplate(
            template: template
        )
        container.templateRepository.setTemplateIdByUSExaminaionType(
            templateId: template.id,
            USExaminationTypeId: template.usExaminationType.id
        )
        syncTemplates()
    }

    func updateTemplate(
        _ template: USExaminationTemplate
    ) {
        container.templateRepository.saveTemplate(
            template: template
        )
        syncTemplates()
    }

    func deleteTemplate(
        id: UUID
    ) {
        container.templateRepository.deleteTemplate(id: id)
        syncTemplates()
    }

    private func syncTemplates() {
        templateIdByUSExaminationTypeId = container.templateRepository
            .getTemplateIdByUSExaminationType()
    }
}

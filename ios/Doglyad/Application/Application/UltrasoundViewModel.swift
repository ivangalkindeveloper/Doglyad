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
            self.neuralModel = model
        } else {
            self.neuralModel = container.usExaminationNeuralModelDefault
        }
        
        let ultrasoundConfig = container.applicationConfig.ultrasound
        if let temperature = ultrasoundModelRepository.getTemperature() {
            self.temperature = temperature
        } else {
            self.temperature = ultrasoundConfig.defaultNeuralModelTemperature
        }
        if let responseLength = ultrasoundModelRepository.getResponseLength() {
            self.responseLength = responseLength
        } else {
            self.responseLength = ultrasoundConfig.defaultNeuralModelResponseLength
        }
        
        self.selectedTemplateIdByExaminationTypeId = container.templateRepository
            .getSelectedTemplateIdByExaminationType()
        self.availableRequestCount = container.ultrasoundModelRepository.remainingRequestCount(
            limit: container.applicationConfig.ultrasound.requestCountPerDay
        )
    }

    var neuralModel: USExaminationNeuralModel
    var temperature: Double
    var responseLength: Int
    var selectedTemplateIdByExaminationTypeId: [String: String]
    var availableRequestCount: Int

    func saveNeuralModel(
        _ model: USExaminationNeuralModel
    ) {
        self.neuralModel = model
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
        container.templateRepository.setSelectedTemplateId(
            id: template.id,
            forExaminationTypeId: template.usExaminationType.id
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
        selectedTemplateIdByExaminationTypeId = container.templateRepository
            .getSelectedTemplateIdByExaminationType()
    }
}

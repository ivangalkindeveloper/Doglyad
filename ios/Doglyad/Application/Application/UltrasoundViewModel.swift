import DoglyadNetwork
import Foundation
import Handler

@MainActor
@Observable
final class UltrasoundViewModel: Handler<DHttpApiError, DHttpConnectionError> {
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

        templateIdByUSExaminationTypeId = [:]
        availableRequestCount = container.applicationConfig.ultrasound.requestCountPerDay
        super.init()
        onInit()
    }

    private func onInit() {
        handle {
            self.templateIdByUSExaminationTypeId = await self.container.templateRepository
                .getTemplatesByUSExaminationId(
                    usExaminationTypesById: self.container.usExaminationTypesById
                )
            self.availableRequestCount = await self.container.ultrasoundModelRepository.remainingRequestCount(
                limit: self.container.applicationConfig.ultrasound.requestCountPerDay
            )
        }
    }

    var neuralModel: USExaminationNeuralModel
    var temperature: Double
    var responseLength: Int
    var templateIdByUSExaminationTypeId: [String: USExaminationTemplate]
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
        let limit = container.applicationConfig.ultrasound.requestCountPerDay
        Task { @MainActor in
            await container.ultrasoundModelRepository.incrementRequestCount()
            self.availableRequestCount = await container.ultrasoundModelRepository.remainingRequestCount(
                limit: limit
            )
        }
    }

    func saveTemplate(
        _ template: USExaminationTemplate
    ) {
        Task { @MainActor in
            await container.templateRepository.saveTemplate(
                template: template
            )
            templateIdByUSExaminationTypeId = await container.templateRepository
                .getTemplatesByUSExaminationId(
                    usExaminationTypesById: container.usExaminationTypesById
                )
        }
    }

    func deleteTemplate(
        id: UUID
    ) {
        Task { @MainActor in
            await container.templateRepository.deleteTemplate(id: id)
            templateIdByUSExaminationTypeId = await container.templateRepository
                .getTemplatesByUSExaminationId(
                    usExaminationTypesById: container.usExaminationTypesById
                )
        }
    }
}

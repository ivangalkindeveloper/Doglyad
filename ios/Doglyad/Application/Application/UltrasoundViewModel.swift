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
        self.availableRequestCount = container.ultrasoundModelRepository.remainingRequestCount(
            limit: container.applicationConfig.ultrasound.requestCountPerDay
        )
    }

    var neuralModel: USExaminationNeuralModel
    var template: String?
    var responseLength: Int?
    var availableRequestCount: Int

    var neuralModelSettings: NeuralModelSettings {
        NeuralModelSettings(
            selectedNeuralModelId: neuralModel.id,
            template: template,
            responseLength: responseLength
        )
    }

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
}

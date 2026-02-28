import DoglyadDatabase

final class ModelRepository: ModelRepositoryProtocol {
    let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }
}

// MARK: USExaminationNeuralModel -

extension ModelRepository {
    func getSelectedUSExaminationNeuralModelId() -> String? {
        database.getSelectedUSExaminationNeuralModelId()
    }

    func setSelectedUSExaminationNeuralModelId(
        id: String
    ) {
        database.setSelectedUSExaminationNeuralModelId(
            value: id
        )
    }
}

// MARK: NeuralModelSettings -

extension ModelRepository {
    func getNeuralModelSettings() -> NeuralModelSettings {
        NeuralModelSettings(
            selectedNeuralModelId: database.getSelectedUSExaminationNeuralModelId(),
            template: database.getNeuralModelResponseTemplate(),
            responseLength: database.getNeuralModelResponseLength()
        )
    }

    func setNeuralModelSettings(settings: NeuralModelSettings) {
        if let selectedNeuralModelId = settings.selectedNeuralModelId {
            database.setSelectedUSExaminationNeuralModelId(value: selectedNeuralModelId)
        }
        database.setNeuralModelResponseTemplate(value: settings.template)
        database.setNeuralModelResponseLength(value: settings.responseLength)
    }
}

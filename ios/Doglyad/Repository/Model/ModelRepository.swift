import DoglyadDatabase

final class ModelRepository: ModelRepositoryProtocol {
    let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }
}

// MARK: NeuralModelSettings -

extension ModelRepository {
    func getNeuralModelSettings() -> NeuralModelSettings {
        NeuralModelSettings(
            template: database.getNeuralModelResponseTemplate(),
            responseLength: database.getNeuralModelResponseLength()
        )
    }

    func setNeuralModelSettings(settings: NeuralModelSettings) {
        database.setNeuralModelResponseTemplate(value: settings.template)
        database.setNeuralModelResponseLength(value: settings.responseLength)
    }
}

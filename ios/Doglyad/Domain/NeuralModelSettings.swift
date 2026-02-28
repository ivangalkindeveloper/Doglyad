import DoglyadDatabase
import Foundation

struct NeuralModelSettings: Codable {
    let selectedNeuralModelId: String?
    let template: String?
    let responseLength: Int?
}

extension NeuralModelSettings {
    static func fromDB(
        _ db: NeuralModelSettingsDB
    ) -> NeuralModelSettings {
        NeuralModelSettings(
            selectedNeuralModelId: db.selectedNeuralModelId,
            template: db.template,
            responseLength: db.responseLength
        )
    }

    func toDB() -> NeuralModelSettingsDB {
        NeuralModelSettingsDB(
            selectedNeuralModelId: selectedNeuralModelId,
            template: template,
            responseLength: responseLength
        )
    }
}

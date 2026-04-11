import DoglyadDatabase
import Foundation

struct NeuralModelSettings: Codable {
    let selectedNeuralModelId: String?
    let temperature: Double?
    let responseLength: Int?
}

extension NeuralModelSettings {
    static func fromDB(
        _ db: NeuralModelSettingsDB
    ) -> NeuralModelSettings {
        NeuralModelSettings(
            selectedNeuralModelId: db.selectedNeuralModelId,
            temperature: db.temperature,
            responseLength: db.responseLength
        )
    }

    func toDB() -> NeuralModelSettingsDB {
        NeuralModelSettingsDB(
            selectedNeuralModelId: selectedNeuralModelId,
            temperature: temperature,
            responseLength: responseLength
        )
    }
}

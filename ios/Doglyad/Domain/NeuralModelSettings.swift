import DoglyadDatabase
import Foundation

struct NeuralModelSettings: Codable {
    let template: String?
    let responseLength: Int?
}

extension NeuralModelSettings {
    static func fromDB(
        _ db: NeuralModelSettingsDB?
    ) -> NeuralModelSettings? {
        guard let db else { return nil }
        return NeuralModelSettings(
            template: db.template,
            responseLength: db.responseLength
        )
    }

    func toDB() -> NeuralModelSettingsDB {
        NeuralModelSettingsDB(
            template: template,
            responseLength: responseLength
        )
    }
}

import DoglyadDatabase
import Foundation

struct USExaminationModelConclusion: Identifiable, Codable, Sendable {
    var id: UUID = .init()
    let date: Date
    let model: String
    let response: String
}

private extension USExaminationModelConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             model,
             response
    }
}

extension USExaminationModelConclusion {
    static func fromDB(
        _ db: USExaminationModelConclusionDB
    ) -> USExaminationModelConclusion {
        USExaminationModelConclusion(
            id: db.id,
            date: db.date,
            model: db.model,
            response: db.response
        )
    }

    func toDB() -> USExaminationModelConclusionDB {
        USExaminationModelConclusionDB(
            id: id,
            date: date,
            model: model,
            response: response
        )
    }
}

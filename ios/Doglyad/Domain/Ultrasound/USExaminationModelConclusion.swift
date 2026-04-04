import DoglyadDatabase
import Foundation

struct USExaminationModelConclusion: Identifiable, Codable, Sendable {
    var id: UUID = .init()
    let date: Date
    let modelId: String
    let response: String
}

private extension USExaminationModelConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             modelId,
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
            modelId: db.modelId,
            response: db.response
        )
    }

    func toDB() -> USExaminationModelConclusionDB {
        USExaminationModelConclusionDB(
            id: id,
            date: date,
            modelId: modelId,
            response: response
        )
    }
}

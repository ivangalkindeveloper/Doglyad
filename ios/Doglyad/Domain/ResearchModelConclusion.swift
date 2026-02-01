import DoglyadDatabase
import Foundation

struct ResearchModelConclusion: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    let date: Date
    let model: String
    let response: String
}

private extension ResearchModelConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             model,
             response
    }
}

extension ResearchModelConclusion {
    static func fromDB(
        _ db: ResearchModelConclusionDB
    ) -> ResearchModelConclusion {
        ResearchModelConclusion(
            id: db.id,
            date: db.date,
            model: db.model,
            response: db.response
        )
    }

    func toDB() -> ResearchModelConclusionDB {
        ResearchModelConclusionDB(
            id: id,
            date: date,
            model: model,
            response: response
        )
    }
}

import DoglyadDatabase
import Foundation

struct ResearchConclusion: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let data: ResearchData
    let actualModelConclusion: ResearchModelConclusion
    let previosModelConclusions: [ResearchModelConclusion]
}

private extension ResearchConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             data,
             actualModelConclusion,
             previosModelConclusions
    }
}

extension ResearchConclusion {
    static func fromDB(
        _ db: ResearchConclusionDB
    ) -> ResearchConclusion {
        ResearchConclusion(
            id: db.id,
            date: db.date,
            data: ResearchData.fromDB(db.data),
            actualModelConclusion: ResearchModelConclusion.fromDB(db.actualModelConclusion),
            previosModelConclusions: db.previosModelConclusions.map { ResearchModelConclusion.fromDB($0) }
        )
    }

    func toDB() -> ResearchConclusionDB {
        ResearchConclusionDB(
            id: id,
            date: date,
            data: data.toDB(),
            actualModelConclusion: actualModelConclusion.toDB(),
            previosModelConclusions: previosModelConclusions.map { $0.toDB() }
        )
    }
}

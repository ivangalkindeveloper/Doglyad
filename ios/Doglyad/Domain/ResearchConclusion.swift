import DoglyadDatabase
import Foundation

struct ResearchConclusion: Identifiable, Codable {
    var id: UUID = .init()
    let date: Date
    let neuralModelSettings: NeuralModelSettings?
    let researchData: ResearchData
    let actualModelConclusion: ResearchModelConclusion
    let previosModelConclusions: [ResearchModelConclusion]
}

private extension ResearchConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             researchData,
             neuralModelSettings,
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
            neuralModelSettings: NeuralModelSettings.fromDB(db.neuralModelSettings),
            researchData: ResearchData.fromDB(db.researchData),
            actualModelConclusion: ResearchModelConclusion.fromDB(db.actualModelConclusion),
            previosModelConclusions: db.previosModelConclusions.map { ResearchModelConclusion.fromDB($0) }
        )
    }

    func toDB() -> ResearchConclusionDB {
        ResearchConclusionDB(
            id: id,
            date: date,
            neuralModelSettings: neuralModelSettings?.toDB(),
            researchData: researchData.toDB(),
            actualModelConclusion: actualModelConclusion.toDB(),
            previosModelConclusions: previosModelConclusions.map { $0.toDB() }
        )
    }
}

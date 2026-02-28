import DoglyadDatabase
import Foundation

struct USExaminationConclusion: Identifiable, Codable {
    var id: UUID = .init()
    let date: Date
    let neuralModelSettings: NeuralModelSettings?
    let examinationData: USExaminationData
    let actualModelConclusion: USExaminationModelConclusion
    let previosModelConclusions: [USExaminationModelConclusion]
}

private extension USExaminationConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             examinationData,
             neuralModelSettings,
             actualModelConclusion,
             previosModelConclusions
    }
}

extension USExaminationConclusion {
    static func fromDB(
        _ db: USExaminationConclusionDB
    ) -> USExaminationConclusion {
        USExaminationConclusion(
            id: db.id,
            date: db.date,
            neuralModelSettings: NeuralModelSettings.fromDB(db.neuralModelSettings),
            examinationData: USExaminationData.fromDB(db.examinationData),
            actualModelConclusion: USExaminationModelConclusion.fromDB(db.actualModelConclusion),
            previosModelConclusions: db.previosModelConclusions.map { USExaminationModelConclusion.fromDB($0) }
        )
    }

    func toDB() -> USExaminationConclusionDB {
        USExaminationConclusionDB(
            id: id,
            date: date,
            neuralModelSettings: neuralModelSettings?.toDB(),
            examinationData: examinationData.toDB(),
            actualModelConclusion: actualModelConclusion.toDB(),
            previosModelConclusions: previosModelConclusions.map { $0.toDB() }
        )
    }
}

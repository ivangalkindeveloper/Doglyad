import Foundation
import SwiftData

@Model
public final class USExaminationConclusionDB {
    public var id: UUID
    public var date: Date
    public var neuralModelSettings: NeuralModelSettingsDB
    public var examinationData: USExaminationDataDB
    public var actualModelConclusion: USExaminationModelConclusionDB
    @Relationship public var previosModelConclusions: [USExaminationModelConclusionDB]

    public init(
        id: UUID = UUID(),
        date: Date,
        neuralModelSettings: NeuralModelSettingsDB,
        examinationData: USExaminationDataDB,
        actualModelConclusion: USExaminationModelConclusionDB,
        previosModelConclusions: [USExaminationModelConclusionDB]
    ) {
        self.id = id
        self.date = date
        self.neuralModelSettings = neuralModelSettings
        self.examinationData = examinationData
        self.actualModelConclusion = actualModelConclusion
        self.previosModelConclusions = previosModelConclusions
    }
}

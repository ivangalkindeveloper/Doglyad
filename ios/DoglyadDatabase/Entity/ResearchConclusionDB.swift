import Foundation
import SwiftData

@Model
public final class ResearchConclusionDB {
    public var id: UUID
    public var date: Date
    public var neuralModelSettings: NeuralModelSettingsDB?
    public var researchData: ResearchDataDB
    public var actualModelConclusion: ResearchModelConclusionDB
    @Relationship public var previosModelConclusions: [ResearchModelConclusionDB]

    public init(
        id: UUID = UUID(),
        date: Date,
        neuralModelSettings: NeuralModelSettingsDB? = nil,
        researchData: ResearchDataDB,
        actualModelConclusion: ResearchModelConclusionDB,
        previosModelConclusions: [ResearchModelConclusionDB] = [],
    ) {
        self.id = id
        self.date = date
        self.neuralModelSettings = neuralModelSettings
        self.researchData = researchData
        self.actualModelConclusion = actualModelConclusion
        self.previosModelConclusions = previosModelConclusions
    }
}

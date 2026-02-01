import Foundation
import SwiftData

@Model
public final class ResearchConclusionDB {
    public var id: UUID
    public var date: Date
    public var data: ResearchDataDB
    public var actualModelConclusion: ResearchModelConclusionDB
    @Relationship public var previosModelConclusions: [ResearchModelConclusionDB]
    
    public init(
        id: UUID = UUID(),
        date: Date,
        data: ResearchDataDB,
        actualModelConclusion: ResearchModelConclusionDB,
        previosModelConclusions: [ResearchModelConclusionDB] = []
    ) {
        self.id = id
        self.date = date
        self.data = data
        self.actualModelConclusion = actualModelConclusion
        self.previosModelConclusions = previosModelConclusions
    }
}

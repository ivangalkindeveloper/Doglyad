import Foundation
import SwiftData

@Model
public final class USExaminationModelConclusionDB {
    public var id: UUID
    public var date: Date
    public var modelId: String
    public var response: String

    public init(
        id: UUID = UUID(),
        date: Date,
        modelId: String,
        response: String
    ) {
        self.id = id
        self.date = date
        self.modelId = modelId
        self.response = response
    }
}

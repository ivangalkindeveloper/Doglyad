import Foundation
import SwiftData

@Model
public final class ResearchModelConclusionDB {
    public var id: UUID
    public var date: Date
    public var model: String
    public var response: String
    
    public init(
        id: UUID = UUID(),
        date: Date,
        model: String,
        response: String
    ) {
        self.id = id
        self.date = date
        self.model = model
        self.response = response
    }
}

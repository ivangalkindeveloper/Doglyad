import Foundation
import SwiftData

@Model
public final class USExaminationTemplateDB {
    public var id: UUID
    public var usExaminationTypeId: String
    public var content: String

    public init(
        id: UUID,
        usExaminationTypeId: String,
        content: String
    ) {
        self.id = id
        self.usExaminationTypeId = usExaminationTypeId
        self.content = content
    }
}

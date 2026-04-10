import Foundation
import SwiftData

@Model
public final class USExaminationTemplateDB {
    @Attribute(.unique) public var id: String
    public var usExaminationTypeId: String
    public var content: String

    public init(
        id: String,
        usExaminationTypeId: String,
        content: String
    ) {
        self.id = id
        self.usExaminationTypeId = usExaminationTypeId
        self.content = content
    }
}

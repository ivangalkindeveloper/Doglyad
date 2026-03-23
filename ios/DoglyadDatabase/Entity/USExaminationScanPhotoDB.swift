import Foundation
import SwiftData

@Model
public final class USExaminationScanPhotoDB {
    public var id: UUID
    public var data: Data

    public init(
        id: UUID = UUID(),
        data: Data
    ) {
        self.id = id
        self.data = data
    }
}

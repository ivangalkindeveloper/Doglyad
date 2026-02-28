import Foundation
import SwiftData

@Model
public final class USExaminationScanPhotoDB {
    public var id: UUID
    public var imageData: Data

    public init(
        id: UUID = UUID(),
        imageData: Data
    ) {
        self.id = id
        self.imageData = imageData
    }
}

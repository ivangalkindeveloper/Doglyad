import Foundation
import SwiftData

@Model
public final class USExaminationScanPhotoDB {
    public var id: UUID
    public var data: Data
    /// A downscaled preview for lists. Optional so that SwiftData migrates
    /// already existing records automatically.
    public var thumbnailData: Data?

    public init(
        id: UUID = UUID(),
        data: Data,
        thumbnailData: Data? = nil
    ) {
        self.id = id
        self.data = data
        self.thumbnailData = thumbnailData
    }
}

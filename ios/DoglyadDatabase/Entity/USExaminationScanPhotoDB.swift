import Foundation
import SwiftData

@Model
public final class USExaminationScanPhotoDB {
    public var id: UUID
    public var data: Data
    /// Уменьшенное превью для списков. Опциональное, чтобы SwiftData
    /// смигрировал уже существующие записи автоматически.
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

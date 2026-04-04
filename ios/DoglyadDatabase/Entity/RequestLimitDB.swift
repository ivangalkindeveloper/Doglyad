import Foundation
import SwiftData

@Model
public final class RequestLimitDB {
    public var count: Int
    public var date: Date

    public init(
        count: Int,
        date: Date
    ) {
        self.count = count
        self.date = date
    }
}

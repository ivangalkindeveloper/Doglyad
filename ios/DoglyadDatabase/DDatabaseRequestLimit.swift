import Foundation
import SwiftData

// MARK: RequestLimit -

public protocol DDatabaseRequestLimitProtocol: AnyObject {
    @MainActor func getRequestLimit() -> RequestLimitDB?

    @MainActor func setRequestLimit(value: RequestLimitDB)

    @MainActor func clearRequestLimit()
}

extension DDatabase: DDatabaseRequestLimitProtocol {
    @MainActor public func getRequestLimit() -> RequestLimitDB? {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor public func setRequestLimit(value: RequestLimitDB) {
        clearRequestLimit()
        container.mainContext.insert(value)
    }

    @MainActor public func clearRequestLimit() {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        guard let items = try? container.mainContext.fetch(descriptor) else { return }
        for item in items {
            container.mainContext.delete(item)
        }
    }
}

import Foundation
import SwiftData

@ModelActor
public actor DRequestLimitStore {
    public func fetchRequestLimit<T: Sendable>(
        _ transform: @Sendable (RequestLimitDB?) -> T
    ) -> T {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        let value = try? modelContext.fetch(descriptor).first
        return transform(value)
    }

    public func setRequestLimit(value: RequestLimitDB) {
        clearRequestLimit()
        modelContext.insert(value)
    }

    public func clearRequestLimit() {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        guard let items = try? modelContext.fetch(descriptor) else { return }
        for item in items {
            modelContext.delete(item)
        }
    }

    public func incrementRequestCount() {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        if let requestLimit = try? modelContext.fetch(descriptor).first,
           Calendar.current.isDateInToday(requestLimit.date)
        {
            requestLimit.count += 1
        } else {
            clearRequestLimit()
            modelContext.insert(RequestLimitDB(count: 1, date: Date()))
        }
    }
}

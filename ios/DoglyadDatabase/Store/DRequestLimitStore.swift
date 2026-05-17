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

    public func setRequestLimit(value: RequestLimitDB) throws {
        try clearRequestLimit()
        modelContext.insert(value)
        try modelContext.save()
    }

    public func clearRequestLimit() throws {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        guard let items = try? modelContext.fetch(descriptor) else { return }
        for item in items {
            modelContext.delete(item)
        }
        try modelContext.save()
    }

    public func incrementRequestCount() throws {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        if let requestLimit = try? modelContext.fetch(descriptor).first,
           Calendar.current.isDateInToday(requestLimit.date)
        {
            requestLimit.count += 1
        } else {
            try clearRequestLimit()
            modelContext.insert(RequestLimitDB(count: 1, date: Date()))
        }
        try modelContext.save()
    }
}

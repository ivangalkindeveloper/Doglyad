import DoglyadDatabase
import Foundation
import RevenueCat

@MainActor
final class RevenueCatSubscriptionRepository: SubscriptionRepositoryProtocol {
    private let apiKey: String
    private let environment: EnvironmentProtocol
    private let database: DDatabaseProtocol

    init(
        apiKey: String,
        environment: EnvironmentProtocol,
        database: DDatabaseProtocol
    ) {
        self.apiKey = apiKey
        self.environment = environment
        self.database = database
    }

    func configure() {
        Purchases.logLevel = environment.type == .development ? .debug : .info
        Purchases.configure(
            withAPIKey: apiKey,
            appUserID: nil,
            purchasesAreCompletedBy: .revenueCat,
            storeKitVersion: .storeKit2
        )
    }

    func cachedStatus(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus? {
        guard let customerInfo = Purchases.shared.cachedCustomerInfo else { return nil }
        return await status(from: customerInfo, configEntitlements: configEntitlements)
    }

    func fetchStatus(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus? {
        let customerInfo = try await Purchases.shared.customerInfo()
        return await status(from: customerInfo, configEntitlements: configEntitlements)
    }

    func restorePurchases(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus? {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return await status(from: customerInfo, configEntitlements: configEntitlements)
    }

    func incrementRequestCount(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus? {
        try? await database.requestLimit.incrementRequestCount()
        let customerInfo = try await Purchases.shared.customerInfo()
        return await status(from: customerInfo, configEntitlements: configEntitlements)
    }

    private func status(
        from customerInfo: CustomerInfo,
        configEntitlements: [String: SubscriptionEntitlement]
    ) async -> SubscriptionStatus? {
        guard let identifier = customerInfo.entitlements.active.first?.key,
              let entitlement = configEntitlements[identifier]
        else {
            return nil
        }
        let availableCountPerDay = await remainingRequestCount(
            limit: entitlement.requestCountPerDay
        )
        return SubscriptionStatus(
            activeEntitlementIdentifier: identifier,
            entitlement: entitlement,
            availableCountPerDay: availableCountPerDay
        )
    }

    private func remainingRequestCount(
        limit: Int
    ) async -> Int {
        await database.requestLimit.fetchRequestLimit { requestLimit in
            guard let requestLimit,
                  Calendar.current.isDateInToday(requestLimit.date)
            else { return limit }
            return max(limit - requestLimit.count, 0)
        }
    }
}

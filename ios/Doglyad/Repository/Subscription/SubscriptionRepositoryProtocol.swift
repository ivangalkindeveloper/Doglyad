import Foundation

@MainActor
protocol SubscriptionRepositoryProtocol: AnyObject {
    func configure()

    func cachedStatus(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus?

    func fetchStatus(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus?

    func restorePurchases(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus?

    func incrementRequestCount(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus?
}

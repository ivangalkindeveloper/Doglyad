import Foundation

@MainActor
protocol SubscriptionRepositoryProtocol: AnyObject {
    func configure()

    func cachedStatus() -> SubscriptionStatus?

    func fetchStatus() async throws -> SubscriptionStatus

    func restorePurchases() async throws -> SubscriptionStatus
}

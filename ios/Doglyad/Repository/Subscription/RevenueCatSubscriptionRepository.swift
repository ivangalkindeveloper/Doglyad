import Foundation
import RevenueCat

@MainActor
final class RevenueCatSubscriptionRepository: SubscriptionRepositoryProtocol {
    private let apiKey: String
    private let environment: EnvironmentProtocol

    init(
        apiKey: String,
        environment: EnvironmentProtocol
    ) {
        self.apiKey = apiKey
        self.environment = environment
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
    ) throws -> SubscriptionStatus? {
        guard let customerInfo = Purchases.shared.cachedCustomerInfo else { return nil }
        return try Self.status(from: customerInfo, configEntitlements: configEntitlements)
    }

    func fetchStatus(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus {
        let customerInfo = try await Purchases.shared.customerInfo()
        return try Self.status(from: customerInfo, configEntitlements: configEntitlements)
    }

    func restorePurchases(
        configEntitlements: [String: SubscriptionEntitlement]
    ) async throws -> SubscriptionStatus {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return try Self.status(from: customerInfo, configEntitlements: configEntitlements)
    }

    /// Resolves the active entitlement and binds its feature set onto the
    /// status, so feature flags can be read directly from the status.
    private static func status(
        from customerInfo: CustomerInfo,
        configEntitlements: [String: SubscriptionEntitlement]
    ) throws -> SubscriptionStatus {
        let activeEntitlement = customerInfo.entitlements.active.first
        guard let identifier = activeEntitlement?.key else {
            fatalError("No identifier found for activeEntitlement")
        }
        guard let configEntetilement = configEntitlements[identifier] else {
            fatalError("No config entitlement found for \(identifier)")
        }
        return SubscriptionStatus(
            isActive: activeEntitlement?.value.isActive == true,
            activeEntitlementIdentifier: identifier,
            entitlement: configEntetilement
        )
    }
}

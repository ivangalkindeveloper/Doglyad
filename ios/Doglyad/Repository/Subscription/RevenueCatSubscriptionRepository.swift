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

    func cachedStatus() -> SubscriptionStatus? {
        guard let customerInfo = Purchases.shared.cachedCustomerInfo else { return nil }
        return Self.status(from: customerInfo)
    }

    func fetchStatus() async throws -> SubscriptionStatus {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return Self.status(from: customerInfo)
        } catch {
            throw SubscriptionError.underlying(error)
        }
    }

    func restorePurchases() async throws -> SubscriptionStatus {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            return Self.status(from: customerInfo)
        } catch {
            throw SubscriptionError.underlying(error)
        }
    }

    private static func status(
        from customerInfo: CustomerInfo
    ) -> SubscriptionStatus {
        let entitlement = customerInfo.entitlements[SubscriptionConfig.entitlementIdentifier]
        return SubscriptionStatus(
            isActive: entitlement?.isActive == true,
            activeProductIdentifier: entitlement?.productIdentifier,
            expirationDate: entitlement?.expirationDate,
            willRenew: entitlement?.willRenew == true,
            managementURL: customerInfo.managementURL
        )
    }
}

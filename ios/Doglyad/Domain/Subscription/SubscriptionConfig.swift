import Foundation

enum SubscriptionConfig {
    static let entitlementIdentifier = "base"
}

struct SubscriptionStatus: Equatable {
    let isActive: Bool
    let activeProductIdentifier: String?
    let expirationDate: Date?
    let willRenew: Bool
    let managementURL: URL?
}

enum SubscriptionError: LocalizedError {
    case notConfigured
    case offeringsUnavailable
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            String(localized: .subscriptionErrorNotConfigured)
        case .offeringsUnavailable:
            String(localized: .subscriptionErrorOfferingsUnavailable)
        case let .underlying(error):
            error.localizedDescription
        }
    }
}

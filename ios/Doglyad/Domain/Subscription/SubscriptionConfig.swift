import Foundation

struct SubscriptionStatus: Equatable {
    let isActive: Bool
    let activeEntitlementIdentifier: String
    let entitlement: SubscriptionEntitlement
}

extension SubscriptionStatus {
    var requestCountPerDay: Int {
        entitlement.requestCountPerDay
    }

    var canFillFormViaMicrophone: Bool {
        entitlement.formCompletionViaMicrophone
    }

    var canSendConclusionByEmail: Bool {
        entitlement.sendingConclusionByEmail
    }
}

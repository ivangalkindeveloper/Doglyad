import Foundation

struct SubscriptionStatus: Equatable {
    let activeEntitlementIdentifier: String
    let entitlement: SubscriptionEntitlement
    let availableCountPerDay: Int
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

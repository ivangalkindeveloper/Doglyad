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

    var formCompletionViaMicrophone: SunscriptionFeatureAvailability {
        entitlement.formCompletionViaMicrophone
    }

    var sendingConclusionByEmail: SunscriptionFeatureAvailability {
        entitlement.sendingConclusionByEmail
    }

    var neuralModelSettings: SunscriptionFeatureAvailability {
        entitlement.neuralModelSettings
    }
}

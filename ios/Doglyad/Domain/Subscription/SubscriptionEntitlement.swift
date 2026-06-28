import Foundation

struct SubscriptionEntitlement: Codable, Equatable {
    let requestCountPerDay: Int
    let formCompletionViaMicrophone: SunscriptionFeatureAvailability
    let sendingConclusionByEmail: SunscriptionFeatureAvailability
    let neuralModelSettings: SunscriptionFeatureAvailability
}

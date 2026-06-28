import Foundation

struct SubscriptionEntitlement: Codable, Equatable {
    let requestCountPerDay: Int
    let formCompletionViaMicrophone: SubscriptionFeatureAvailability
    let sendingConclusionByEmail: SubscriptionFeatureAvailability
    let neuralModelSettings: SubscriptionFeatureAvailability
}

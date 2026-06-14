import Foundation

struct SubscriptionEntitlement: Codable, Equatable {
    let requestCountPerDay: Int
    let formCompletionViaMicrophone: Bool
    let sendingConclusionByEmail: Bool
}

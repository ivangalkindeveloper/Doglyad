import Foundation

/// A paid feature of the app. A single identity used to query availability
/// through `SubscriptionViewModel.availability(of:)`.
enum PaidFeature {
    case neuralModelSettings
    case formCompletionViaMicrophone
    case sendingConclusionByEmail
}

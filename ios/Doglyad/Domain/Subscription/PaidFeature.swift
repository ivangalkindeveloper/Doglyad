import Foundation

/// Платная фича приложения. Единая точка идентичности для запроса доступности
/// через `SubscriptionViewModel.availability(of:)`.
enum PaidFeature {
    case neuralModelSettings
    case formCompletionViaMicrophone
    case sendingConclusionByEmail
}

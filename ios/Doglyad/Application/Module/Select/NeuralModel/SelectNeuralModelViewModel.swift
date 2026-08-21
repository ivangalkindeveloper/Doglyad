import Foundation
import NestedObservableObject
import Router

@MainActor
final class SelectNeuralModelViewModel: DViewModel {
    private let container: DependencyContainer
    private let router: DRouter
    private let arguments: SelectNeuralModelArguments?
    @NestedObservableObject private var subscription: SubscriptionViewModel

    init(
        container: DependencyContainer,
        router: DRouter,
        arguments: SelectNeuralModelArguments?,
        subscription: SubscriptionViewModel
    ) {
        self.container = container
        self.router = router
        self.arguments = arguments
        _subscription = NestedObservableObject(wrappedValue: subscription)
        super.init()
    }

    var models: [USExaminationNeuralModel] {
        container.usExaminationNeuralModels
    }

    func isSelected(_ model: USExaminationNeuralModel) -> Bool {
        arguments?.currentValue == model
    }

    func isProBadgeVisible(for model: USExaminationNeuralModel) -> Bool {
        switch model.entitlement {
        case .base:
            return false
        case .pro:
            switch subscription.status?.type {
            case .some(.pro):
                return false
            case .some(.base), .none:
                return true
            }
        }
    }

    func isComingSoonBadgeVisible(for model: USExaminationNeuralModel) -> Bool {
        switch model.accessibility {
        case .available, .unavailable:
            return false
        case .comingSoon:
            return true
        }
    }

    func isSelectionEnabled(for model: USExaminationNeuralModel) -> Bool {
        switch model.accessibility {
        case .available:
            return true
        case .comingSoon, .unavailable:
            return false
        }
    }

    func onModelTap(_ model: USExaminationNeuralModel) {
        guard isSelectionEnabled(for: model) else { return }

        if isPaywallRequired(for: model) {
            router.dismissSheet()
            router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
            return
        }

        router.dismissSheet()
        arguments?.onSelected(model)
    }

    private func isPaywallRequired(for model: USExaminationNeuralModel) -> Bool {
        isProBadgeVisible(for: model)
    }
}

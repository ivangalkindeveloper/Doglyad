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
        model.entitlement == .pro
    }

    func onModelTap(_ model: USExaminationNeuralModel) {
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
        model.entitlement == .pro && subscription.status?.type != .pro
    }
}

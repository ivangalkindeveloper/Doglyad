import Router

@MainActor
final class SubscriptionScreenViewModel: DViewModel {
    private let router: DRouter
    private let arguments: SubscriptionScreenArguments?

    init(
        router: DRouter,
        arguments: SubscriptionScreenArguments?
    ) {
        self.router = router
        self.arguments = arguments
        super.init()
    }

    func onTapBack() {
        router.pop()
    }

    func onTapChangeType() {
        router.push(
            route: RouteScreen(
                type: .subscriptionPaywall
            )
        )
    }

    func onTapSupportCenter() {
        router.push(
            route: RouteSheet(
                type: .subscriptionCustomerCenter
            )
        )
    }
}

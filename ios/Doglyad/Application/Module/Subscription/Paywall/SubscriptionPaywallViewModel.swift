import RevenueCat
import Router

@MainActor
final class SubscriptionPaywallViewModel: DViewModel {
    private let router: DRouter
    private let arguments: SubscriptionPaywallArguments?
    private let onRefreshStatus: () async -> Void

    init(
        router: DRouter,
        arguments: SubscriptionPaywallArguments?,
        onRefreshStatus: @escaping () async -> Void
    ) {
        self.router = router
        self.arguments = arguments
        self.onRefreshStatus = onRefreshStatus
        super.init()
    }

    func onCompleted() {
        handle {
            await self.onRefreshStatus()
        }
    }

    func onRequestedDismissal() {
        if router.path.isEmpty {
            router.root(
                route: RouteScreen(
                    type: .scan
                )
            )
        } else {
            router.pop()
        }
    }
}

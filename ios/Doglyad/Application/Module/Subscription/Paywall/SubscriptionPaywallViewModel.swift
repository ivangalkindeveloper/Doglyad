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

    func onPurchaseCompleted() {
        handle {
            await self.onRefreshStatus()
        } onMainSuccess: { _ in
            self.dismissPaywall()
        }
    }

    func onRestoreCompleted(
        customerInfo: CustomerInfo
    ) {
        handle {
            await self.onRefreshStatus()
        } onMainSuccess: { _ in
            if !customerInfo.entitlements.active.isEmpty {
                self.dismissPaywall()
            }
        }
    }

    func onRequestedDismissal() {
        handle {
            await self.onRefreshStatus()
        } onMainSuccess: { _ in
            self.dismissPaywall()
        }
    }

    private func dismissPaywall() {
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

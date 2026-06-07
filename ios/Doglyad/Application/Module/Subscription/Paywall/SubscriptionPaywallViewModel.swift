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
        Task {
            await onRefreshStatus()
            dismissPaywall()
        }
    }

    func onRestoreCompleted(
        customerInfo: CustomerInfo
    ) {
        Task {
            await onRefreshStatus()
            if customerInfo.entitlements[SubscriptionConfig.entitlementIdentifier]?.isActive == true {
                dismissPaywall()
            }
        }
    }

    func onRequestedDismissal() {
        Task {
            await onRefreshStatus()
            dismissPaywall()
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

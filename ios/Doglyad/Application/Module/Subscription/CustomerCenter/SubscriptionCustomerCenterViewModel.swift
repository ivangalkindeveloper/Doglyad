import Router

@MainActor
final class SubscriptionCustomerCenterViewModel: DViewModel {
    private let router: DRouter
    private let arguments: SubscriptionCustomerCenterArguments?
    private let onRefreshStatus: () async -> Void

    init(
        router: DRouter,
        arguments: SubscriptionCustomerCenterArguments?,
        onRefreshStatus: @escaping () async -> Void
    ) {
        self.router = router
        self.arguments = arguments
        self.onRefreshStatus = onRefreshStatus
        super.init()
    }

    func onRestoreCompleted() {
        Task {
            await onRefreshStatus()
        }
    }
}

import Router

@MainActor
final class RequestViewModel: DViewModel {
    private let router: DRouter

    init(
        router: DRouter
    ) {
        self.router = router
        super.init()
    }

    func onTapUpgrade() {
        router.dismissSheet()
        router.push(
            route: RouteScreen(
                type: .subscriptionPaywall
            )
        )
    }

    func onTapBack() {
        router.dismissSheet()
    }
}

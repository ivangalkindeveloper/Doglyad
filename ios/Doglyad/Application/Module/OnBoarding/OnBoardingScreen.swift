import DoglyadUI
import Router
import SwiftUI

struct OnBoardingScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: OnBoardingScreenArguments?

    var body: some View {
        OnBoardingScreenView(
            viewModel: OnBoardingViewModel(
                container: container,
                router: router,
                refreshSubscriptionStatus: { [subscriptionViewModel] in
                    await subscriptionViewModel.refreshStatus()
                },
                getIsActive: { [subscriptionViewModel] in
                    subscriptionViewModel.isActive
                }
            )
        )
    }
}

#Preview {
    OnBoardingScreen(
        arguments: nil
    )
    .previewable()
}

import Router
import SwiftUI

struct SubscriptionPaywallScreen: View {
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: SubscriptionPaywallArguments?

    var body: some View {
        SubscriptionPaywallScreenView(
            viewModel: SubscriptionPaywallViewModel(
                router: router,
                arguments: arguments,
                onRefreshStatus: { [weak subscriptionViewModel] in
                    await subscriptionViewModel?.refreshStatus()
                }
            )
        )
    }
}

#Preview {
    SubscriptionPaywallScreen(
        arguments: nil
    )
    .previewable()
}

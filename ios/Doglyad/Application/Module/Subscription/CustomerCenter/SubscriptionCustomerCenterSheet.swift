import Router
import SwiftUI

struct SubscriptionCustomerCenterSheet: View {
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: SubscriptionCustomerCenterArguments?

    var body: some View {
        SubscriptionCustomerCenterSheetView(
            viewModel: SubscriptionCustomerCenterViewModel(
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
    SubscriptionCustomerCenterSheet(
        arguments: nil
    )
    .previewable()
}

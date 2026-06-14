import Router
import SwiftUI

struct SubscriptionScreen: View {
    @EnvironmentObject private var router: DRouter
    let arguments: SubscriptionScreenArguments?

    var body: some View {
        SubscriptionScreenView(
            viewModel: SubscriptionScreenViewModel(
                router: router,
                arguments: arguments
            )
        )
    }
}

#Preview {
    SubscriptionScreen(
        arguments: nil
    )
    .previewable()
}

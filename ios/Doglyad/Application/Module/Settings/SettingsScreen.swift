import DoglyadUI
import Router
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: SettingsScreenArguments?

    var body: some View {
        SettingsScreenView(
            viewModel: SettingsViewModel(
                container: container,
                router: router,
                getIsActive: { [weak subscriptionViewModel] in
                    subscriptionViewModel?.isActive ?? false
                }
            )
        )
    }
}

#Preview {
    SettingsScreen(
        arguments: nil
    )
    .previewable()
}

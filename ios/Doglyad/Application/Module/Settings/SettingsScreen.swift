import DoglyadUI
import Router
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: SettingsScreenArguments?

    var body: some View {
        SettingsScreenView(
            viewModel: SettingsViewModel(
                environment: container.environment,
                usExaminationRepository: container.usExaminationRepository,
                router: router
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

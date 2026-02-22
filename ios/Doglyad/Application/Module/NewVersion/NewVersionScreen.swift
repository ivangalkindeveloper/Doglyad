import DoglyadUI
import Router
import SwiftUI

struct NewVersionScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    let arguments: NewVersionScreenArguments?

    var body: some View {
        NewVersionScreenView(
            viewModel: NewVersionViewModel(
                environment: container.environment,
                applicationConfig: container.applicationConfig
            )
        )
    }
}

#Preview {
    NewVersionScreen(
        arguments: nil
    )
    .previewable()
}

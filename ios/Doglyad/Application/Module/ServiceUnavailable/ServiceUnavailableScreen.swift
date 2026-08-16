import DoglyadUI
import Router
import SwiftUI

struct ServiceUnavailableScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    let arguments: ServiceUnavailableScreenArguments?

    var body: some View {
        ServiceUnavailableScreenView(
            viewModel: ServiceUnavailableViewModel(
                container: container
            )
        )
    }
}

#Preview {
    ServiceUnavailableScreen(
        arguments: nil
    )
    .previewable()
}

import DoglyadUI
import Router
import SwiftUI

struct NewVersionScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    let arguments: NewVersionScreenArguments?

    var body: some View {
        NewVersionScreenView(
            viewModel: NewVersionViewModel(
                container: container
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

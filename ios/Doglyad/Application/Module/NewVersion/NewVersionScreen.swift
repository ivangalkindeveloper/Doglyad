import DoglyadUI
import Router
import SwiftUI

struct NewVersionScreen: View {
    @Environment(DependencyContainer.self) private var container
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

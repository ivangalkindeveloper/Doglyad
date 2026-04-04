import DoglyadUI
import Router
import SwiftUI

struct StorageScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DMessager.self) private var messager
    @EnvironmentObject private var router: DRouter
    let arguments: StorageScreenArguments?

    var body: some View {
        StorageScreenView(
            viewModel: StorageViewModel(
                container: container,
                messager: messager,
                router: router
            )
        )
    }
}

#Preview {
    StorageScreen(
        arguments: nil
    )
    .previewable()
}

import DoglyadUI
import Router
import SwiftUI

struct StorageScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messanger: DMessager
    @EnvironmentObject private var router: DRouter
    let arguments: StorageScreenArguments?

    var body: some View {
        StorageScreenView(
            viewModel: StorageViewModel(
                diagnosticRepository: container.diagnosticsRepository,
                messanger: messanger,
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

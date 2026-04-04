import DoglyadUI
import Router
import SwiftUI

struct ScanScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DMessager.self) private var messager
    @EnvironmentObject private var router: DRouter
    let arguments: ScanScreenArguments?

    var body: some View {
        ScanScreenView(
            viewModel: ScanViewModel(
                container: container,
                messager: messager,
                router: router
            )
        )
    }
}

#Preview {
    ScanScreen(
        arguments: nil
    )
    .previewable()
}

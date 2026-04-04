import DoglyadUI
import Router
import SwiftUI

struct HistoryScreen: View {
    @Environment(DependencyContainer.self) private var container
    @EnvironmentObject private var router: DRouter
    let arguments: HistoryScreenArguments?

    var body: some View {
        HistoryScreenView(
            viewModel: HistoryViewModel(
                container: container,
                router: router
            )
        )
    }
}

#Preview {
    HistoryScreen(
        arguments: nil
    )
    .previewable()
}

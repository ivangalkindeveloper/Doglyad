import DoglyadUI
import Router
import SwiftUI

struct HistoryScreen: View {
    @EnvironmentObject private var container: DependencyContainer
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

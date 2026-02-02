import DoglyadUI
import Router
import SwiftUI

final class HistoryScreenArguments: RouteArgumentsProtocol {}

struct HistoryScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: HistoryScreenArguments?

    var body: some View {
        HistoryScreenView(
            viewModel: HistoryViewModel(
                diagnosticRepository: container.diagnosticsRepository,
                router: router
            )
        )
    }
}

#Preview {
    PreviewWrapperView(
        screenType: .history,
        arguments: nil
    )
}

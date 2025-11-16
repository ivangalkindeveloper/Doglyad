import SwiftUI
import Router
import DoglyadUI

final class HistoryScreenArguments: RouteArgumentsProtocol {}
    
struct HistoryScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: HistoryScreenArguments?

    var body: some View {
        HistoryScreenView(
            viewModel: HistoryViewModel(
                diagnosticRepository: container.diagnosticsRepository,
                router: router,
            )
        )
    }
}

private struct HistoryScreenView: View {
    @EnvironmentObject var theme: DTheme
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }
    
    @StateObject var viewModel: HistoryViewModel
    
    var body: some View {
        DScreen(
            title: .historyTitle,
            onTapBack: viewModel.onTapBack
        ) {
            ScrollView(
                showsIndicators: false
            ) {
                
            }
        }
    }
}

#Preview {
    HistoryScreen(
        arguments: nil
    )
}

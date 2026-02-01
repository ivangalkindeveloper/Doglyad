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

private struct HistoryScreenView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: HistoryViewModel

    var body: some View {
        DScreen(
            title: .historyTitle,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    spacing: .zero
                ) {
                    if viewModel.conclusions.isEmpty {
                        HistoryEmptyView()
                    } else {
                        VStack(
                            spacing: .zero
                        ) {
                            ForEach(viewModel.conclusions) { conclusion in
                                HistoryCard(
                                    conclusion: conclusion,
                                    action: {
                                        viewModel.onTapConclusion(value: conclusion)
                                    }
                                )
                                .padding(size.s4)
                            }
                        }
                    }
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    PreviewWrapperView(
        screenType: .history,
        arguments: nil
    )
}

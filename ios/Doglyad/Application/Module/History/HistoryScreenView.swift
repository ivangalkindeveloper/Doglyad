import DoglyadUI
import SwiftUI

struct HistoryScreenView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

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
                    alignment: .leading,
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
        .onAppear {
            viewModel.onAppear()
        }
        .environmentObject(viewModel)
    }
}

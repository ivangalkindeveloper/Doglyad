import DoglyadUI
import Foundation
import SwiftUI

struct RecievedConclusionBottomSheetView: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }

    @StateObject var viewModel: RecievedConclusionViewModel

    var body: some View {
        DBottomSheet(
            type: .blur,
            title: .conclusionTitle,
            fraction: 0.9,
            content: { toolbarHeight in
                VStack(
                    spacing: .zero
                ) {
                    ScrollView {
                        DMarkdown(
                            content: viewModel.displayedResponse,
                            textColor: color.grayscaleBackgroundWeak
                        )
                        .padding(.top, toolbarHeight + size.s4)
                        .padding(.vertical, size.s8)
                        .padding(.horizontal, size.s18)
                        .padding(.bottom, size.s128)
                    }
                    .mask(
                        VStack(
                            spacing: .zero
                        ) {
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: size.s16)

                            Color.black
                        }
                    )
                }
            },
            bottom: {
                VStack(
                    spacing: size.s8
                ) {
                    DButton(
                        title: .buttonToConclusion,
                        action: viewModel.onTapConclusion
                    )
                    .dStyle(.primaryButton)

                    if viewModel.isUserEmailAvailable {
                        DButton(
                            image: .send,
                            title: viewModel.userEmailButtonTitle,
                            action: viewModel.onTapUserEmail,
                            isLoading: viewModel.isLoading
                        )
                        .dStyle(.textWeak)
                        .padding(.bottom, size.s10)
                    }
                }
                .padding(.top, size.s8)
                .padding(.horizontal, size.s16)
            }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
}

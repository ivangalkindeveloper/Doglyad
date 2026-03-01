import DoglyadUI
import SwiftUI

struct RecievedConclusionBottomSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: RecievedConclusionViewModel

    var body: some View {
        DBlurBottomSheet(
            title: .conclusionTitle,
            fraction: 0.5
        ) {
            VStack(
                spacing: .zero
            ) {
                ScrollView {
                    DText(viewModel.conclusionResponse)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscaleBackgroundWeak,
                            alignment: .leading
                        )
                        .padding(.horizontal, size.s16)
                        .offset(y: viewModel.isAppeared ? 0 : -20)
                        .opacity(viewModel.isAppeared ? 1 : 0)
                }
                .mask(
                    VStack(spacing: .zero) {
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: size.s16)

                        Color.black

                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: size.s16)
                    }
                )

                HStack(
                    spacing: size.s8
                ) {
                    DButton(
                        title: .buttonCopy,
                        action: viewModel.onTapCopy
                    )
                    .dStyle(.primaryButton)

                    DButton(
                        title: .buttonToConclusion,
                        action: viewModel.onTapConclusion
                    )
                    .dStyle(.primaryButton)
                }
                .padding(.top, size.s16)
                .padding(.horizontal, size.s16)
            }
            .padding(.bottom, size.s16)
        }
        .animation(
            theme.animation,
            value: viewModel.isAppeared
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
}

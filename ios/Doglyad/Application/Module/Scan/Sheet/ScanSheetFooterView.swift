import SwiftUI
import DoglyadUI

struct ScanSheetFooterView: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }

    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        VStack(
            spacing: .zero
        ) {
            Spacer()
            if viewModel.sheetController.isTop {
                VStack(
                    spacing: .zero
                ) {
                    if container.isResearchNeuralModelAvailable {
                        if !viewModel.isLoading {
                            DButton(
                                image: .microphone,
                                title: .buttonSpeech,
                                action: viewModel.onTapSpeech
                            )
                            .dStyle(.primaryChip)
                            .shimmering(
                                animation: Animation.linear(duration: 1.5).delay(2.4).repeatForever(autoreverses: false),
                                gradient: Gradient(colors: [
                                    .white.opacity(0.3),
                                    .white,
                                    .white.opacity(0.3)
                                ]),
                                bandSize: 0.6,
                                mode: .overlay(blendMode: .overlay)
                            )
                            .padding(.bottom, size.s8)
                            .transition(.move(edge: .bottom))
                        }
                    }

                    DButton(
                        title: .buttonScan,
                        action: viewModel.onTapScan
                    )
                    .dStyle(.primaryButton)
                    .padding(size.s16)
                    .safeAreaPadding(.bottom)
                    .background(
                        color.grayscaleBackground
                            .clipShape(
                                DRoundedCorner(
                                    radius: size.adaptiveCornerRadius,
                                    corners: [.topLeft, .topRight]
                                )
                            )
                            .shadow(
                                color: color.grayscaleBody.opacity(0.2),
                                radius: size.s16
                            )
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(
            theme.animation,
            value: viewModel.sheetController.currentPosition
        )
    }
}

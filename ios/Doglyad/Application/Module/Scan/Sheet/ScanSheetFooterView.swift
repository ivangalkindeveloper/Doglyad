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
                        DButton(
                            image: .microphone,
                            title: .buttonSpeech,
                            action: viewModel.onTapSpeech
                        )
                        .dStyle(.primaryChip)
                        .padding(.bottom, size.s8)
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

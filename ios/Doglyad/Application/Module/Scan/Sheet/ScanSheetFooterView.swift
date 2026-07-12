import DoglyadUI
import SwiftUI

struct ScanSheetFooterView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }

    @EnvironmentObject private var viewModel: ScanViewModel
    // Observed so the footer re-renders (and viewModel.isSpeechButtonVisible refreshes) when the subscription status changes.
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel

    var body: some View {
        VStack(
            spacing: .zero
        ) {
            Spacer()
            if viewModel.sheetController.isTop {
                VStack(
                    spacing: .zero
                ) {
                    if viewModel.isSpeechButtonVisible {
                        if !viewModel.isLoading {
                            DBadge(
                                .entitlementPro,
                                isVisible: viewModel.isSpeechButtonProBadgeVisible && !viewModel.isLoading,
                                isShimmering: true
                            ) {
                                DButton(
                                    image: .microphone,
                                    title: .buttonSpeech,
                                    action: viewModel.onTapSpeech
                                )
                                .dStyle(.primaryChip)
                                .dShimmer(isShimmering: viewModel.isSpeechButtonShimmering)
                            }
                            .padding(.bottom, size.s8)
                            .transition(.move(edge: .bottom))
                        }
                    }

                    DButton(
                        title: .buttonScan,
                        action: viewModel.onTapScan,
                        isLoading: viewModel.isLoading
                    )
                    .dStyle(.primaryButton)
                    .padding(size.s16)
                    .safeAreaPadding(.bottom)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .clipShape(
                                DRoundedCorner(
                                    radius: size.adaptiveCornerRadius,
                                    corners: [.topLeft, .topRight]
                                )
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
        .animation(
            theme.animation,
            value: viewModel.isLoading
        )
    }
}

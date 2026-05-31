import DoglyadUI
import SwiftUI

struct ShareBottomSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: ShareViewModel

    var body: some View {
        DBottomSheet(
            title: .shareTitle,
            fraction: viewModel.isUserEmailAvailable ? 0.4 : 0.3
        ) { toolbarHeight in
            VStack(
                spacing: size.s8
            ) {
                if viewModel.isUserEmailAvailable {
                    DButtonCard(
                        action: viewModel.onTapUserEmail
                    ) {
                        HStack(
                            spacing: size.s8
                        ) {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                DIcon(
                                    .send,
                                    color: color.grayscaleHeader
                                )
                            }
                            DText(viewModel.userEmailButtonTitle)
                                .dStyle(
                                    font: typography.linkSmall
                                )
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                DButtonCard(
                    action: viewModel.onTapEmail
                ) {
                    row(
                        icon: .mail,
                        title: .buttonShareEmail
                    )
                }
                .disabled(viewModel.isLoading)

                DButtonCard(
                    action: viewModel.onTapCopy
                ) {
                    row(
                        icon: .copy,
                        title: .buttonCopy
                    )
                }
                .disabled(viewModel.isLoading)

                ShareLink(
                    item: viewModel.shareMessage
                ) {
                    row(
                        icon: .export,
                        title: .buttonShare
                    )
                }
                .buttonStyle(DButtonStyle(.card))
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding(.top, toolbarHeight + size.s16)
            .padding(.horizontal, size.s16)
        }
    }

    private func row(
        icon: ImageResource,
        title: LocalizedStringResource
    ) -> some View {
        HStack(
            spacing: size.s8
        ) {
            DIcon(
                icon,
                color: color.grayscaleHeader
            )
            DText(title)
                .dStyle(
                    font: typography.linkSmall
                )
            Spacer()
        }
    }
}

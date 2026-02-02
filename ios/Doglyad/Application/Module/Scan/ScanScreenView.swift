import BottomSheet
import DoglyadUI
import SwiftUI

struct ScanScreenView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: ScanViewModel
    @FocusState private var focus: ScanViewModel.Focus?

    var body: some View {
        DScreen(
            toolbarType: .blur,
            backgroundColor: color.grayscaleHeader,
            leading: {
                DButton(
                    image: .hambergerMenu,
                    action: viewModel.onTapSettings
                )
                .dStyle(.circle)
            },
            titleContent: {
                DButton(
                    title: .forResearchType(viewModel.researchType),
                    action: viewModel.onTapResearchType
                )
                .dStyle(.primaryChip)
            },
            onTapBody: viewModel.unfocus,
            content: { _ in
                ZStack {
                    ZStack {
                        ScanCameraView()

                        VStack(
                            spacing: .zero
                        ) {
                            Spacer()
                            ScanCaptureView()
                        }
                    }
                    .bottomSheet(
                        bottomSheetPosition: $viewModel.sheetController.currentPosition,
                        switchablePositions: viewModel.sheetController.switchablePositions,
                        headerContent: {
                            ScanSheetHeaderView()
                        },
                        mainContent: {
                            ScanSheetBodyView(
                                focus: $focus
                            )
                        }
                    )
                    .enableBackgroundBlur(false)
                    .showCloseButton(false)
                    .enableContentDrag(false)
                    .customBackground(
                        color.grayscaleBackgroundWeak
                            .clipShape(
                                DRoundedCorner(
                                    radius: size.adaptiveCornerRadius,
                                    corners: [.topLeft, .topRight]
                                )
                            )
                    )
                    .showDragIndicator(true)
                    .dragIndicatorColor(color.grayscaleLine)
                    .enableSwipeToDismiss(false)
                    .enableTapToDismiss(false)

                    ScanSheetFooterView()
                }
                .ignoresSafeArea(.keyboard)
            }
        )
        .onSubmit {
            viewModel.onSubmit()
        }
        .onTapGesture {
            viewModel.unfocus()
        }
        .onChange(of: focus, initial: true) { _, newValue in
            guard viewModel.focus != newValue else { return }
            viewModel.focus = newValue
        }
        .onChange(of: viewModel.focus, initial: true) { _, newValue in
            guard focus != newValue else { return }
            focus = newValue
        }
        .onChange(of: viewModel.photos, initial: true) {
            viewModel.onChangePhotosForSheet()
        }
        .onChange(of: viewModel.sheetController.currentPosition, initial: true) {
            viewModel.onChangeSheetForCamera()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .environmentObject(viewModel)
    }
}

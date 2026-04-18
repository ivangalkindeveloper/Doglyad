import BottomSheet
import DoglyadUI
import SwiftUI

struct ScanScreenView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: ScanViewModel
    @FocusState private var focus: ScanViewModel.Focus?

    var body: some View {
        DScreen(
            toolbarType: .blur,
            backgroundColor: .black,
            leading: {
                DButton(
                    image: .hambergerMenu,
                    action: viewModel.onTapSettings
                )
                .dStyle(.circle)
            },
            titleContent: {
                DButton(
                    title: viewModel.usExaminationType.getLocalizedTitle(for: Locale.current),
                    action: viewModel.onTapUSExaminationType
                )
                .dStyle(.primaryChip)
            },
            onTapBody: viewModel.unfocus,
            content: { _ in
                @Bindable var viewModel = self.viewModel

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
                        switchablePositions: self.viewModel.sheetController.switchablePositions,
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
            self.viewModel.onDisappear()
        }
        .environment(viewModel)
    }
}

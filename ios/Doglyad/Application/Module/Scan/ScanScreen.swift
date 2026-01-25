import BottomSheet
import DoglyadCamera
import DoglyadUI
import Router
import SwiftUI

final class ScanScreenArguments: RouteArgumentsProtocol {}

struct ScanScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: ScanScreenArguments?

    var body: some View {
        ScanScreenView(
            viewModel: ScanViewModel(
                permissionManager: container.permissionmanager,
                diagnosticRepository: container.diagnosticsRepository,
                router: router
            )
        )
    }
}

private struct ScanScreenView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: ScanViewModel

    var body: some View {
        DScreen(
            toolbarType: .blur,
            backgroundColor: color.grayscaleHeader,
            leading: {
                DButton(
                    image: .hambergerMenu,
                    action: viewModel.onTapHistory,
                )
                .dStyle(.circle)
            },
            titleContent: {
                DButton(
                    title: .forResearchType(viewModel.researchType),
                    action: viewModel.onTapResearchType,
                )
                .dStyle(.primaryChip)
            },
            content: { toolbarInset in
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
                            ScanSheetBodyView()
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

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
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: ScanViewModel

    var body: some View {
        DScreen(
            backgroundColor: color.grayscaleHeader,
        ) {
            ZStack {
                ZStack {
                    ScanCameraView()
                    
                    VStack(
                        spacing: .zero
                    ) {
                        ScanHeaderView()
                        Spacer()
                        ScanCaptureView()
                    }
                    .padding(size.s16)
                }
                .bottomSheet(
                    bottomSheetPosition: $viewModel.sheetController.currentPosition,
                    switchablePositions: viewModel.sheetController.switchablePositions,
                    headerContent: {
                        ScanSheetPhotosView()
                    },
                    mainContent: {
                        ScanSheetView()
                    }
                )
                .enableBackgroundBlur(false)
                .showCloseButton(false)
                .enableContentDrag(false)
                .customBackground(
                    color.grayscaleBackgroundWeak
                        .clipShape(
                            DRoundedCorner(
                                radius: size.s32,
                                corners: [.topLeft, .topRight]
                            )
                        )
                )
                .showDragIndicator(true)
                .dragIndicatorColor(color.grayscaleLine)
                .enableSwipeToDismiss(false)
                .enableTapToDismiss(false)

                VStack(
                    spacing: .zero
                ) {
                    Spacer()
                    if viewModel.sheetController.isTop {
                        VStack(
                            spacing: .zero
                        ) {
                            DButton(
                                image: .microphone,
                                title: .buttonSpeech,
                                action: viewModel.onTapSpeech
                            )
                            .dStyle(.primaryChip)
                            .padding(.bottom, size.s8)
                            
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
                                            radius: size.s32,
                                            corners: [.topLeft, .topRight]
                                        )
                                    )
                                    .shadow(color: color.grayscaleBody.opacity(0.2), radius: size.s16)
                            )
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
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
        .animation(
            theme.animation,
            value: viewModel.sheetController.currentPosition
        )
        .environmentObject(viewModel)
    }
}



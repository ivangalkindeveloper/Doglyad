import BottomSheet
import DoglyadCamera
import DoglyadUI
import Router
import SwiftUI

final class ScanScreenArguments: RouteArgumentsProtocol {}

struct ScanScreen: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: ScanScreenArguments?
    @StateObject private var viewModel = ScanViewModel()

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
                                action: viewModel.onPressedSpeech
                            )
                            .dStyle(.primaryChip)
                            .padding(.bottom, size.s8)
                            
                            DButton(
                                title: .buttonScan,
                                action: viewModel.onPressedScan
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
        .onAppear {
            viewModel.onAppear(
                container: container,
                router: router
            )
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

// #Preview {
//    ApplicationWrapperView {
//        DThemeWrapperView {
//            ScanScreen(
//                arguments: nil
//            )
//        }
//    }
// }

//
//  AnamnesisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import BottomSheet
import DoglyadUI
import Router
import SwiftUI
import DoglyadCamera

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
                DCameraView(
                    controller: viewModel.cameraController
                )
                .ignoresSafeArea()

                ScanFrameView()
                    .ignoresSafeArea()

                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        DButton(
                            image: .hambergerMenu,
                            action: viewModel.onPressedHistory,
                        )
                        .dStyle(.circle)

                        Spacer()

                        DButton(
                            title: .forResearchType(viewModel.researchType),
                            action: viewModel.onPressedResearchType,
                        )
                        .dStyle(.primaryChip)
                        .padding([.trailing, .leading], size.s16)

                        Spacer()

                        Color.clear
                            .frame(
                                width: size.s56,
                                height: size.s56,
                            )
                    }
                    .padding(.bottom, size.s16)

                    Spacer()

                    DButton(
                        image: viewModel.captureIcon,
                        action: viewModel.onPressedCapture,
                        isLoading: viewModel.cameraController.isCapturing
                    )
                    .dStyle(.primaryCircle)
                    .padding(size.s16)

                    DText(
                        .scanCaptureDescription,
                    )
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleLine,
                        alignment: .center
                    )
                    .padding(.bottom, viewModel.sheetController.isSheetVisible ? size.s128 : .zero)
                }
                .padding(size.s16)
            }
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
        .enableAppleScrollBehavior(true)
        .enableBackgroundBlur(false)
        .showCloseButton(false)
        .enableContentDrag(true)
        .customBackground(
            color.grayscaleBackgroundWeak
                .clipShape(
                    RoundedCorner(
                        radius: size.s32,
                        corners: [.topLeft, .topRight]
                    )
                )
        )
        .showDragIndicator(true)
        .dragIndicatorColor(color.grayscaleLine)
        .enableSwipeToDismiss(false)
        .enableTapToDismiss(false)
        .animation(
            theme.animation,
            value: viewModel.sheetController.currentPosition
        )
        .onChange(of: viewModel.photos, initial: true) {
            viewModel.determineOpeningSheet()
        }
        .onAppear {
            viewModel.initialize(
                container: container,
                router: router
            )
        }
        .onDisappear {
            viewModel.cameraController.stopSession()
        }
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

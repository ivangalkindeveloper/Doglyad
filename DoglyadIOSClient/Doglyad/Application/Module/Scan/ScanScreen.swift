//
//  AnamnesisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import DoglyadUI
import Router
import SwiftUI
import BottomSheet

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
    @StateObject private var sheetViewModel = ScanSheetViewModel()
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        DScreen(
            backgroundColor: theme.color.grayscaleHeader,
        ) {
            ZStack {
                CameraView(
                    viewModel: cameraViewModel
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

                        if let researchType = viewModel.researchType {
                            DButton(
                                title: L10n.forUSResearchType(researchType.type).string,
                                action: viewModel.onPressedResearchType,
                            )
                            .dStyle(.primaryChip)
                            .padding([.trailing, .leading], size.s16)
                        }

                        Spacer()

                        Rectangle()
                            .fill(.clear)
                            .frame(
                                width: size.s56,
                                height: size.s56,
                            )
                    }
                    .padding(.bottom, size.s16)

                    Spacer()

                    DButton(
                        image: .camera,
                        action: {
                            cameraViewModel.takePhoto(
                                completion: { image in
                                    viewModel.capturePhoto(image: image)
                                }
                            )
                        },
                        isLoading: cameraViewModel.isCapturing
                    )
                    .dStyle(.primaryCircle)
                    .padding(size.s16)
                    
                    DText(
                        L10n.scanDescription.string,
                    )
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleLine,
                        alignment: .center
                    )
                    .padding(.bottom, sheetViewModel.isSheetVisible ? size.s96 : .zero)
                }
                .padding(size.s16)
            }
        }
        .bottomSheet(
            bottomSheetPosition: $sheetViewModel.sheetPosition,
            switchablePositions: [
                sheetViewModel.sheetPositionHidden,
                sheetViewModel.sheetPositionBottom,
                sheetViewModel.sheetPositionTop,
            ]
        ) {
            ScanSheet()
        }
        .customBackground(
            color.grayscaleBackgroundWeak
                .cornerRadius(size.s16)
        )
        .enableBackgroundBlur(false)
        .showCloseButton(false)
        .enableContentDrag(true)
        .enableSwipeToDismiss(false)
        .dragIndicatorColor(color.grayscaleLine)
        .animation(
            .easeOut(duration: 0.1),
            value: sheetViewModel.sheetPosition
        )
        .onChange(of: viewModel.photos, initial: true) {
            let photos = viewModel.photos
            if photos.isEmpty {
                sheetViewModel.setHidden()
            } else {
                sheetViewModel.setBottom()
            }
        }
        .onAppear {
            viewModel.initialize(
                container: container,
                router: router
            )
        }
        .onDisappear {
            cameraViewModel.stopSession()
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

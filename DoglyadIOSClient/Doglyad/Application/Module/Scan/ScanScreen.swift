//
//  AnamnesisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

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
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        DScreen {
            ZStack {
                CameraView(
                    viewModel: cameraViewModel
                )
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

                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height / 2
                        let color = color.grayscaleBackground
                        let lineWidth = size.s8 / 4
                        let cornerRadius: CGFloat = size.s64

                        ZStack() {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: cornerRadius))
                                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                                path.addQuadCurve(
                                    to: CGPoint(x: cornerRadius, y: 0),
                                    control: CGPoint(x: 0, y: 0)
                                )
                                path.addLine(to: CGPoint(x: cornerRadius, y: 0))
                            }
                            .stroke(color, lineWidth: lineWidth)

                            Path { path in
                                path.move(to: CGPoint(x: w - cornerRadius, y: 0))
                                path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: w, y: cornerRadius),
                                    control: CGPoint(x: w, y: 0)
                                )
                                path.addLine(to: CGPoint(x: w, y: cornerRadius))
                            }
                            .stroke(color, lineWidth: lineWidth)

                            Path { path in
                                path.move(to: CGPoint(x: 0, y: h - cornerRadius))
                                path.addLine(to: CGPoint(x: 0, y: h - cornerRadius))
                                path.addQuadCurve(
                                    to: CGPoint(x: cornerRadius, y: h),
                                    control: CGPoint(x: 0, y: h)
                                )
                                path.addLine(to: CGPoint(x: cornerRadius, y: h))
                            }
                            .stroke(color, lineWidth: lineWidth)

                            Path { path in
                                path.move(to: CGPoint(x: w - cornerRadius, y: h))
                                path.addLine(to: CGPoint(x: w - cornerRadius, y: h))
                                path.addQuadCurve(
                                    to: CGPoint(x: w, y: h - cornerRadius),
                                    control: CGPoint(x: w, y: h)
                                )
                                path.addLine(to: CGPoint(x: w, y: h - cornerRadius))
                            }
                            .stroke(color, lineWidth: lineWidth)
                        }
                        .frame(width: w, height: h, alignment: .center)
                    }
                    .padding(.bottom, size.s16)

                    DButton(
                        image: .camera,
                        action: {
                            cameraViewModel.takePhoto(
                                completion: { image in
                                    self.viewModel.capturePhoto(image: image)
                                }
                            )
                        },
                        isLoading: cameraViewModel.isCapturing
                    )
                    .dStyle(.primaryCircle)
                    .padding(.bottom, viewModel.isShowBottomSheet ? size.s96 : .zero)
                }
                .padding(size.s16)
            }
        }
        .sheet(
            isPresented: $viewModel.isShowBottomSheet
        ) {
            ScanBottomSheet()
        }
        .animation(
            .easeOut(duration: 0.1),
            value: viewModel.isShowBottomSheet
        )
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

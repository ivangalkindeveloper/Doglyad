import DoglyadCamera
import DoglyadUI
import Shimmer
import SwiftUI

struct ScanCameraView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @Environment(ScanViewModel.self) private var viewModel

    var body: some View {
        Group {
            if viewModel.cameraController.isLoading {
                color.grayscaleBackground
                    .shimmering()
            } else {
                ZStack {
                    DCameraView(
                        controller: viewModel.cameraController
                    )
                    .if(!viewModel.cameraController.isRunning) { view in
                        view
                            .blur(radius: size.s16)
                    }

                    if viewModel.cameraController.isRunning {
                        ScanFrameView()
                    } else {
                        VStack(
                            alignment: .center
                        ) {
                            DText(
                                .scanTurnedOffCameraDescription
                            )
                            .dStyle(
                                font: typography.textSmall,
                                color: color.grayscaleLine,
                                alignment: .center
                            )
                            .padding(.bottom, size.s16)

                            if !viewModel.isPhotoFilling {
                                DButton(
                                    title: .buttonCameraTurnOn
                                ) {
                                    viewModel.cameraController.startSession()
                                }
                                .dStyle(.chip)
                            }
                        }
                        .padding(size.s32)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .animation(
            theme.animation,
            value: viewModel.cameraController.isRunning
        )
        .animation(
            theme.animation,
            value: viewModel.isPhotoFilling
        )
    }
}

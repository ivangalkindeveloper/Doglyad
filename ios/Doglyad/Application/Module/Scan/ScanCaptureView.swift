import DoglyadUI
import SwiftUI

struct ScanCaptureView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        VStack(
            spacing: .zero
        ) {
            if viewModel.isPhotoFilling {
                DButton(
                    image: .down,
                    action: viewModel.onTapCapture
                )
                .dStyle(.primaryCircle)
            } else if viewModel.isCaptureAvailable {
                VStack(
                    spacing: size.s8
                ) {
                    DButton(
                        image: viewModel.captureIcon,
                        action: viewModel.onTapCapture,
                        isLoading: viewModel.cameraController.isCapturing
                    )
                    .dStyle(.primaryCircle)

                    DText(.scanCaptureDescription)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscaleLine,
                            alignment: .center
                        )
                }
            }
        }
        .padding(size.s16)
        .padding(.bottom, viewModel.sheetController.isSheetVisible ? size.s136 : .zero)
        .animation(
            theme.animation,
            value: viewModel.sheetController.currentPosition
        )
    }
}

#Preview {
    ScanCaptureView()
}

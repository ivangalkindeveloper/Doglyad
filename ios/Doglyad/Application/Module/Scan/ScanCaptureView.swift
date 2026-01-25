import SwiftUI
import DoglyadUI

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
                    spacing: .zero
                ) {
                    DButton(
                        image: viewModel.captureIcon,
                        action: viewModel.onTapCapture,
                        isLoading: viewModel.cameraController.isCapturing
                    )
                    .dStyle(.primaryCircle)
                    
                    if !viewModel.isPhotoFilling {
                        DText(.scanCaptureDescription)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscaleLine,
                            alignment: .center
                        )
                        .padding(.top, size.s16)
                    }
                }
            }
        }
        .padding(size.s16)
        .padding(.bottom, viewModel.sheetController.isSheetVisible ? size.s116 : .zero)
        .animation(
            theme.animation,
            value: viewModel.sheetController.currentPosition
        )
        

    }
}

#Preview {
    ScanCaptureView()
}

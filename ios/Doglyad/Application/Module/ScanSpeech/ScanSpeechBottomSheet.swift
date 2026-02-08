import DoglyadUI
import Router
import SwiftUI

struct ScanSpeechBottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: ScanSpeechBottomSheetArguments

    var body: some View {
        ScanSpeechBottomSheetView(
            viewModel: ScanSpeechViewModel(
                researchNeuralModel: container.researchNeuralModel,
                router: router,
                arguments: arguments
            )
        )
    }
}

private struct ScanSpeechBottomSheetView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: ScanSpeechViewModel

    var body: some View {
        DBlurBottomSheet(
            title: .speechTitle,
            fraction: 0.5
        ) {
            VStack(
                spacing: .zero
            ) {
                Spacer()

                if viewModel.speechController.isRecording {
                    if let speechText = viewModel.speechController.text {
                        DText(speechText)
                            .dStyle(
                                font: typography.linkSmall,
                                color: color.grayscaleBackgroundWeak,
                                alignment: .center
                            )
                            .lineLimit(1)
                            .truncationMode(.head)
                            .clipped()
                            .padding(.horizontal, size.s32)
                            .padding(.bottom, size.s8)
                    }

                    ScanSpeechAudioMeterView(
                        level: viewModel.speechController.audioMeter
                    )
                    .padding(.bottom, size.s16)
                }

                if !viewModel.speechController.isRecording {
                    DText(.speechProcessDescription)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscaleBackgroundWeak,
                            alignment: .center
                        )
                        .padding(.horizontal, size.s16)
                        .padding(.bottom, size.s8)
                }

                DText(.speechProcessSpeechDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleBackgroundWeak,
                        alignment: .center
                    )
                    .padding(.horizontal, size.s16)

                Spacer()

                DButton(
                    image: viewModel.speechIcon,
                    action: viewModel.onTapSpeech,
                    isLoading: viewModel.isLoading
                )
                .dStyle(.primaryCircle)
            }
            .padding(size.s16)
        }
        .animation(
            theme.animation,
            value: viewModel.speechController.isRecording
        )
        .animation(
            theme.animation,
            value: viewModel.speechController.text
        )
    }
}

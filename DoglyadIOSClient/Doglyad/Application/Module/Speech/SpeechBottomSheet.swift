import DoglyadUI
import Router
import SwiftUI

final class SpeechBottomSheetArguments: RouteArgumentsProtocol {
    let completion: (String) -> Void
    
    init(
        completion: @escaping (String) -> Void
    ) {
        self.completion = completion
    }
}

struct SpeechBottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: SpeechBottomSheetArguments
    
    var body: some View {
        SpeechBottomSheetView(
            viewModel: SpeechViewModel(
                researchNeuralModel: container.researchNeuralModel,
                router: router,
                arguments: arguments
            )
        )
    }
}

private struct SpeechBottomSheetView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: SpeechViewModel

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
                            .padding(.bottom, size.s4)
                    }
                    
                    SpeechAudioMeterView(
                        level: viewModel.speechController.audioMeter
                    )
                    .padding(.bottom, size.s16)
                }

                DText(.speechProcessDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleBackgroundWeak,
                        alignment: .center
                    )
                    .padding(.horizontal, size.s16)
                    .padding(.bottom, size.s4)
                
                DText(viewModel.speechKeys.map({ value in
                    "\"\(String(localized: value))\""
                }).joined(separator: ", "))
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleBackgroundWeak,
                        alignment: .center
                    )
                    .padding(.horizontal, size.s16)
                
                Spacer()
                
                DButton(
                    image: viewModel.speechIcon,
                    action: viewModel.onTapSpeech
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

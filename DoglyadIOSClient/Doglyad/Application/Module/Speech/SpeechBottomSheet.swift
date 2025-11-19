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
    @EnvironmentObject private var router: DRouter
    let arguments: SpeechBottomSheetArguments?
    
    var body: some View {
        SpeechBottomSheetView(
            viewModel: SpeechViewModel(
                router: router
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
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
//                .blur(radius: size.s16)
            
            VStack(
                spacing: .zero
            ) {
                HStack(
                    spacing: .zero
                ) {
                    Spacer()
                    
                    Button {
                        viewModel.onTapBack()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(color.grayscaleLine)
                            .padding(size.s10)
                    }
                }
                
                Spacer()
                
                // Animation
                
                DText(.speechProcessDescription)
                    .dStyle(
                        font: typography.textMedium,
                        color: color.grayscaleBackgroundWeak,
                        alignment: .center
                    )
                    .padding(.bottom, size.s16)
                
                Grid(
                    alignment: .center,
                ) {
                    ForEach(Array(viewModel.speechKeys.enumerated()), id: \.offset) { key in
                        DText("\"\(String(localized: key.element))\"")
                            .dStyle(
                                font: typography.textMedium,
                                color: color.grayscaleBackgroundWeak
                            )
                    }
                }
                .padding(.bottom, size.s32)
                
                Spacer()
                
                DButton(
                    image: viewModel.speechIcon,
                    action: viewModel.onTapSpeech
                )
                .dStyle(.primaryCircle)
            }
            .padding(size.s16)
        }
        .presentationBackground(.clear)
        .presentationCornerRadius(size.s32)
        .presentationDetents([.fraction(0.6)])
    }
}

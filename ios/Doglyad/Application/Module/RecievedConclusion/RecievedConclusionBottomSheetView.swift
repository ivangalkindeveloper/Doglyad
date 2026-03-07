import DoglyadUI
import SwiftUI

struct RecievedConclusionBottomSheetView: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: RecievedConclusionViewModel

    var body: some View {
        DBottomSheet(
            type: .blur,
            title: .conclusionTitle,
            fraction: 0.9,
            content: {
                VStack(
                    spacing: .zero
                ) {
                    if let modelTitle = container.getUSExaminationNeuralModelById(id: viewModel.model.modelId)?.title {
                        DText(modelTitle)
                            .dStyle(
                                font: typography.linkSmall,
                                color: color.grayscaleBackgroundWeak
                            )
                            .padding(.bottom, size.s8)
                    }

                    ScrollView {
                        DText(viewModel.displayedResponse)
                            .dStyle(
                                font: typography.textSmall,
                                color: color.grayscaleBackgroundWeak,
                                alignment: .leading
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, size.s4)
                            .padding(.vertical, size.s8)
                            .padding(.horizontal, size.s16)
                            .padding(.bottom, size.s128)
                    }
                    .mask(
                        VStack(spacing: .zero) {
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: size.s16)

                            Color.black
                        }
                    )
                }
            },
            bottom: {
                VStack(
                    spacing: size.s18
                ) {
                    DButton(
                        title: .buttonToConclusion,
                        action: viewModel.onTapConclusion
                    )
                    .dStyle(.primaryButton)
                    
                    Button(
                        action: viewModel.onTapCopy
                    ) {
                        HStack(
                            spacing: size.s8
                        ) {
                            DIcon(
                                .copy,
                                color: color.grayscaleBackgroundWeak
                            )
                            DText(.buttonCopy)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscaleBackgroundWeak,
                                    alignment: .center
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, size.s8)
                }
                .padding(.top, size.s8)
                .padding(.horizontal, size.s16)
            }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
}

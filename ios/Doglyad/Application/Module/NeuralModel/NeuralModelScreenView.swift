import DoglyadUI
import SwiftUI

struct NeuralModelScreenView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: NeuralModelViewModel
    @FocusState private var focus: NeuralModelViewModel.Focus?

    var body: some View {
        DScreen(
            title: .neuralModelTitle,
            onTapBack: viewModel.onTapBack,
            content: { toolbarInset in
                ScrollView(
                    showsIndicators: false
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        DListButtonCard(
                            title: .neuralModeModelLabel,
                            description: LocalizedStringResource(
                                stringLiteral: viewModel.usExaminationNeuralModel.title
                            ),
                            action: viewModel.onTapNeuralModel
                        )
                        .padding(.bottom, size.s4)

                        DButtonCard(
                            action: { viewModel.toggleIsMarkdown() }
                        ) {
                            HStack(alignment: .center) {
                                DText(.neuralModelMarkdownLabel)
                                    .dStyle(
                                        font: typography.linkSmall
                                    )
                                Spacer(minLength: size.s16)
                                Toggle(
                                    "",
                                    isOn: $viewModel.isMarkdown
                                )
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .allowsHitTesting(false)
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .foregroundStyle(color.grayscaleHeader)
                        }
                        .padding(.bottom, size.s4)

                        DText(.neuralModelMarkdownDescription)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(.horizontal, size.s8)
                            .padding(.bottom, size.s16)

                        DTextField(
                            controller: viewModel.temperatureController,
                            focus: DTextFieldFocus(
                                value: .temperature,
                                state: $focus
                            ),
                            title: .neuralModelTemperatureLabel,
                            placeholder: .neuralModelTemperaturePlaceholder,
                            keyboardType: .decimalPad,
                            sumbitLabel: .next
                        )
                        .padding(.bottom, size.s4)

                        DText(.neuralModelTemperatureDescription)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(.horizontal, size.s8)
                            .padding(.bottom, size.s16)

                        DTextField(
                            controller: viewModel.responseLengthController,
                            focus: DTextFieldFocus(
                                value: .length,
                                state: $focus
                            ),
                            title: .neuralModelResponseLengthLabel,
                            placeholder: .neuralModelResponseLengthPlaceholder,
                            keyboardType: .numberPad,
                            sumbitLabel: .done
                        )
                        .padding(.bottom, size.s4)

                        DText(.neuralModelResponseLengthDescription)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(.horizontal, size.s8)
                    }
                    .padding(size.s16)
                    .padding(.top, toolbarInset)
                    .padding(.bottom, size.s64)
                }
            },
            bottom: {
                DButton(
                    title: .buttonSave,
                    action: viewModel.onTapSave
                )
                .dStyle(.primaryButton)
                .padding(size.s16)
            }
        )
        .onTapGesture {
            viewModel.unfocus()
        }
        .onSubmit {
            viewModel.onSubmit()
        }
        .onChange(of: focus, initial: true) { _, newValue in
            guard viewModel.focus != newValue else { return }
            viewModel.focus = newValue
        }
        .onChange(of: viewModel.focus, initial: true) { _, newValue in
            guard focus != newValue else { return }
            focus = newValue
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

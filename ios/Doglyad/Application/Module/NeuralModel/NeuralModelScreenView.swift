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
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollView(
                showsIndicators: false
            ) {
                VStack(
                    alignment: .leading,
                    spacing: .zero
                ) {
                    DTextField(
                        controller: viewModel.templateController,
                        focus: DTextFieldFocus(
                            value: .template,
                            state: $focus
                        ),
                        title: .neuralModelTemplateLabel,
                        placeholder: .neuralModelTemplatePlaceholder,
                        sumbitLabel: .next
                    )
                    .padding(.bottom, size.s4)

                    DText(.neuralModelTemplateDescription)
                        .dStyle(
                            font: typography.textXSmall,
                            color: color.grayscalePlacehold
                        )
                        .padding(.horizontal, size.s8)
                        .padding(.bottom, size.s4)
                    
                    DText(.neuralModelTemplateExampleDescription)
                        .dStyle(
                            font: typography.textXSmall,
                            color: color.grayscalePlacehold
                        )
                        .padding(size.s8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(color.grayscaleInput.opacity(0.6))
                        .cornerRadius(size.s12)
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
                        .padding(.bottom, size.s32)

                    DButton(
                        title: .buttonScan,
                        action: viewModel.onTapSave
                    )
                    .dStyle(.primaryButton)
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
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
}

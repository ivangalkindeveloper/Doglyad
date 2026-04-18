import DoglyadUI
import SwiftUI

struct TemplateEditScreenView: View {
    @Environment(UltrasoundViewModel.self) private var ultrasoundViewModel
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: TemplateEditViewModel
    @FocusState private var focus: TemplateAddViewModel.Focus?

    var body: some View {
        DScreen(
            title: .templateEditTitle,
            onTapBack: viewModel.onTapBack,
            onTapBody: viewModel.unfocus,
            content: { toolbarInset in
                ScrollView(
                    showsIndicators: false
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        DListButtonCard(
                            title: .templateExaminationTypeLabel,
                            description: viewModel.usExaminationType.getLocalizedTitle(for: Locale.current),
                            action: viewModel.onTapExaminationType
                        )
                        .padding(.bottom, size.s4)

                        DTextField(
                            controller: viewModel.templateController,
                            focus: DTextFieldFocus(
                                value: .content,
                                state: $focus
                            ),
                            title: .templateContentLabel,
                            placeholder: .templateContentPlaceholder,
                            sumbitLabel: .done
                        )
                        .padding(.bottom, size.s16)

                        DText(.templateContentDescription)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(.bottom, size.s4)

                        DText(.templateExampleDescription)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .padding(size.s8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(color.grayscaleInput.opacity(0.6))
                            .cornerRadius(size.s12)
                            .padding(.bottom, size.s16)
                    }
                    .padding(size.s16)
                    .padding(.top, toolbarInset)
                    .padding(.bottom, size.s32)
                }
                .scrollDismissesKeyboard(.interactively)
            },
            bottom: {
                VStack(
                    spacing: .zero
                ) {
                    DButton(
                        title: .buttonSave,
                        action: {
                            viewModel.onTapSave(ultrasoundViewModel: ultrasoundViewModel)
                        }
                    )
                    .dStyle(.primaryButton)
                    .padding(.bottom, size.s8)

                    DButton(
                        title: .templateDeleteButton,
                        action: {
                            viewModel.onTapDelete(ultrasoundViewModel: ultrasoundViewModel)
                        }
                    )
                    .dStyle(.card)
                }
                .padding(size.s16)
            }
        )
        .environment(viewModel)
    }
}

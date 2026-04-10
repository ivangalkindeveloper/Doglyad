import DoglyadUI
import SwiftUI

struct TemplateAddScreenView: View {
    @Environment(UltrasoundViewModel.self) private var ultrasoundViewModel
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @State var viewModel: TemplateAddViewModel

    var body: some View {
        DScreen(
            title: .templateAddTitle,
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
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
                        title: .templateContentLabel,
                        placeholder: .templateContentPlaceholder,
                        sumbitLabel: .done
                    )
                    .padding(.bottom, size.s4)

                    DText(.templateContentDescription)
                        .dStyle(
                            font: typography.textXSmall,
                            color: color.grayscalePlacehold
                        )
                        .padding(.horizontal, size.s8)
                        .padding(.bottom, size.s32)

                    DButton(
                        title: .buttonSave,
                        action: {
                            viewModel.onTapSave(ultrasoundViewModel: ultrasoundViewModel)
                        }
                    )
                    .dStyle(.primaryButton)
                }
                .padding(size.s16)
                .padding(.top, toolbarInset)
                .padding(.bottom, size.s32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .environment(viewModel)
    }
}

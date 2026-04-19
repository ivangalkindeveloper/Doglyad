import DoglyadUI
import SwiftUI

struct ScanSheetTemplateCardView: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @Environment(ScanViewModel.self) private var viewModel
    @Environment(UltrasoundViewModel.self) private var ultrasoundViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            DText(.scanTemplateCardTitleLabel)
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlacehold
                )
                .padding(.horizontal, size.s8)
                .padding(.bottom, size.s8)

            DButtonCard(
                action: {
                    viewModel.onTapSelectedTemplate(ultrasoundViewModel: ultrasoundViewModel)
                }
            ) {
                VStack(
                    alignment: .leading,
                    spacing: size.s8
                ) {
                    DText(
                        viewModel.usExaminationType.getLocalizedTitle(for: Locale.current)
                    )
                    .dStyle(
                        font: typography.linkSmall
                    )

                    if let template = viewModel.selectedTemplate(ultrasoundViewModel: ultrasoundViewModel) {
                        DText(template.content)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(4)
                    } else {
                        DText(.scanTemplateCardNoTemplateLabel)
                            .dStyle(
                                font: typography.textXSmall,
                                color: color.grayscalePlacehold
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

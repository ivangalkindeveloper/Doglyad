import DoglyadUI
import SwiftUI

struct TemplateListItemCard: View {
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let examinationTypeTitle: LocalizedStringResource
    let templateContent: String
    let action: () -> Void

    var body: some View {
        DButtonCard(
            action: action
        ) {
            VStack(
                alignment: .leading,
                spacing: size.s8
            ) {
                DText(examinationTypeTitle)
                    .dStyle(
                        font: typography.linkSmall,
                        color: color.grayscaleBackground
                    )
                    .multilineTextAlignment(.leading)
                    .padding(size.s10)
                    .background(
                        Capsule()
                            .fill(color.gradientPrimaryWeak)
                    )

                DText(templateContent)
                    .dStyle(
                        font: typography.textXSmall,
                        color: color.grayscalePlacehold
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TemplateListItemCard(
        examinationTypeTitle: "Щитовидная железа",
        templateContent: """
        Проведено ультразвуковое исследование.
        Размеры долей симметричные.
        Паренхима однородная.
        Очаговых образований не выявлено.
        Дополнительная строка для обрезки.
        """,
        action: {}
    )
    .padding()
    .dThemeWrapper()
}

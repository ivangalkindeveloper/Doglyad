import DoglyadUI
import SwiftUI

struct ModelConclusionCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let conclusion: ResearchModelConclusion

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            DText(.conclusionModelResponseLabel)
                .dStyle(
                    font: typography.linkSmall
                )
            
            HStack(
                alignment: .bottom,
                spacing: .zero
            ) {
                
                DText(.conclusionResponseModelLabel)
                    .dStyle(
                        font: typography.textSmall
                    )
                    .padding(.trailing, size.s4)

                DText(conclusion.model)
                    .dStyle(
                        font: typography.linkSmall
                    )
            }
            
            HStack(
                alignment: .bottom,
                spacing: .zero
            ) {
                
                DText(.conclusionResponseDateLabel)
                    .dStyle(
                        font: typography.textSmall
                    )
                    .padding(.trailing, size.s4)

                DText(conclusion.date.localized())
                    .dStyle(
                        font: typography.linkSmall
                    )
            }
            .padding(.bottom, size.s8)

            ExpandableText(
                text: conclusion.response,
                backgroundColor: color.grayscaleBackground,
                collapsedLineLimit: 5
            )
        }
        .padding(size.s16)
        .background(color.grayscaleBackground)
        .cornerRadius(size.s16)
    }
}

#Preview {
    ModelConclusionCard(
        conclusion: ResearchModelConclusion(
            date: Date(),
            model: "google/medgemma-3-27B",
            response: """
            Щитовидная железа расположена типично, структура органа сохранена.
            Размеры обеих долей находятся в пределах возрастной нормы, отклонений не выявлено.
            Эхогенность паренхимы равномерная, без участков патологического снижения или повышения.
            Очаговых образований, узлов, кист и кальцинатов не обнаружено.
            Контуры железы ровные, чёткие, капсула не утолщена.
            Кровоток по данным цветового допплеровского картирования не усилен, соответствует физиологическим значениям.
            Регионарные лимфатические узлы визуализируются без признаков увеличения или структурных изменений.
            Признаков воспалительных процессов или аутоиммунного поражения не отмечено.
            Полученные данные соответствуют нормальной ультразвуковой картине щитовидной железы.
            Рекомендуется плановое контрольное УЗИ по необходимости или по назначению врача.
            """
        )
    )
    .padding()
    .dThemeWrapper()
}

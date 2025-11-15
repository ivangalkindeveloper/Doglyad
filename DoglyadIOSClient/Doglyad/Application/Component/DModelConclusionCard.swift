import DoglyadUI
import SwiftUI

struct DModelConclusionCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let conclusion: ResearchModelConclusion

    @State private var isExpanded = false
    private var collapsedHeight: Double {
        size.s116
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            VStack(
                alignment: .leading,
                spacing: .zero
            ) {
                DText(
                    .conclusionModelResponseLabel,
                )
                .dStyle(
                    font: typography.linkSmall,
                )
                
                HStack(
                    alignment: .bottom,
                    spacing: .zero
                ) {
                    DText(
                        .conclusionDateLabel,
                    )
                    .dStyle(
                        font: typography.textSmall,
                    )
                    .padding(.trailing, size.s4)
                    
                    DText(
                        conclusion.date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits).hour().minute().second().locale(Locale(identifier: "ru_RU")))
                    )
                    .dStyle(
                        font: typography.linkSmall,
                    )
                }
                .padding(.bottom, size.s4)
                
                DText(
                    conclusion.description,
                )
                .dStyle(
                    font: typography.textSmall,
                )
            }
            .overlay(
                collapsedMask
            )
            .frame(height: isExpanded ? nil : collapsedHeight)
            .padding(.bottom, size.s16)

            Button(
                action: {
                    isExpanded.toggle()
                }
            ) {
                HStack(
                    spacing: 0
                ) {
                    if isExpanded {
                        DText(
                            .buttonCollapse
                        )
                        .dStyle(
                            font: typography.linkSmall,
                            color: color.primaryDefault
                        )
                        .padding(.trailing, size.s12)
                        DIcon(
                            .up,
                            color: color.primaryDefault
                        )
                        .frame(
                            width: size.s8,
                            height: size.s8
                        )
                    } else {
                        DText(
                            .buttonExpand
                        )
                        .dStyle(
                            font: typography.linkSmall,
                            color: color.primaryDefault
                        )
                        .padding(.trailing, size.s12)
                        DIcon(
                            .down,
                            color: color.primaryDefault
                        )
                        .frame(
                            width: size.s8,
                            height: size.s8
                        )
                    }

                }
            }
            .frame(maxWidth: .infinity) // Центровка кнопки
            .padding(.bottom, size.s8)
        }
        .padding(size.s16)
        .background(color.grayscaleBackground)
        .cornerRadius(size.s16)
        .animation(
            theme.animation,
            value: isExpanded
        )
    }
}

private extension DModelConclusionCard {
    private var collapsedMask: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                color.grayscaleBackground.opacity(0),
                color.grayscaleBackground.opacity(1),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: collapsedHeight)
        .opacity(isExpanded ? 0 : 1)
    }
}

#Preview {
    DThemeWrapperView {
        DModelConclusionCard(
            conclusion: ResearchModelConclusion(
                date: Date(),
                description: """
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
    }
}

import SwiftUI
import DoglyadUI

struct HistoryCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let conclusion: ResearchConclusion
    let action: () -> Void
    
    var body: some View {
        DButtonCard(
            action: action
        ) {
            HStack(
                spacing: .zero
            ) {
                ZStack {
                    ForEach(Array(conclusion.photos.enumerated()), id: \.element.id) { index, photo in
                        PhotoCard(image: photo.image)
                             .offset(x: Double.random(in: -8...8), y: Double.random(in: -8...8))
                             .rotationEffect(.degrees(Double.random(in: -24...24)))
                             .zIndex(Double(index))
                     }
                 }
                .padding(.trailing, size.s20)
                
                VStack(
                    alignment: .leading,
                    spacing: .zero
                ) {
                    HStack(
                        spacing: .zero
                    ) {
                        DText(conclusion.patientName)
                            .dStyle(
                                font: typography.linkSmall
                            )
                            .padding(.trailing, size.s8)
                        DText(conclusion.date.localized())
                            .dStyle(
                                font: typography.textSmall,
                                color: color.grayscaleLabel
                            )
                    }

                    DText(LocalizedStringResource.forResearchType(conclusion.researchType))
                        .dStyle(
                            font: typography.linkSmall,
                            color: color.grayscalePlaceholder
                        )
                    DText(conclusion.researchDescription)
                        .dStyle(
                            font: typography.textSmall,
                            color: color.grayscaleLabel
                        )
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(color.grayscaleBackground)
        .cornerRadius(size.s16)
    }
}

#Preview {
    DThemeWrapperView{
        HistoryCard(
            conclusion: ResearchConclusion(
                date: Date(),
                researchType: .thyroidGland,
                photos: [
                    ResearchScanPhoto(image: UIImage(resource: .alertInfo)),
                    ResearchScanPhoto(image: UIImage(resource: .alertInfo)),
                    ResearchScanPhoto(image: UIImage(resource: .alertInfo))
                ],
                patientName: "Пациент#0",
                patientGender: .male,
                patientDateOfBirth: Date(),
                patientHeight: 180.0,
                patientWeight: 80.0,
                patientComplaint: """
                Пациент отмечает периодическое чувство давления в области шеи.
                Сообщает о небольшом дискомфорте при глотании в течение последних двух недель.
                Также упоминает общую слабость и повышенную утомляемость.
                Ранее подобные симптомы не наблюдались.
                Жалоб на боль нет.
                """,
                researchDescription: """
                Проведено ультразвуковое исследование щитовидной железы в стандартных продольных и поперечных проекциях.
                Размеры долей симметричные, контуры ровные и чёткие.
                Паренхима однородная, эхогенность умеренная.
                Очаговых образований не выявлено.
                Региональные лимфоузлы без особенностей.
                """,
                additionalData: """
                Исследование выполнено на ультразвуковом аппарате экспертного класса.
                Использован линейный датчик высокой частоты 7–12 МГц.
                Настройки оптимизированы для визуализации поверхностных структур.
                Качество изображения стабильное на протяжении всего исследования.
                Архивирование изображения выполнено автоматически.
                """,
                actualModelConclusion: ResearchModelConclusion(
                    date: Date(),
                    model: "medgemma-3-27B",
                    description: """
                    Признаков узловых или кистозных изменений щитовидной железы не выявлено.
                    Размеры органа в пределах возрастной нормы.
                    Эхоструктура паренхимы сохранена, патологических включений нет.
                    Данных за воспалительный процесс не получено.
                    УЗ-картина соответствует норме.
                    """
                ),
                previosModelConclusions: [
                    ResearchModelConclusion(
                        date: Date(),
                        model: "medgemma-3-27B",
                        description: """
                        Признаков узловых или кистозных изменений щитовидной железы не выявлено.
                        Размеры органа в пределах возрастной нормы.
                        Эхоструктура паренхимы сохранена, патологических включений нет.
                        Данных за воспалительный процесс не получено.
                        УЗ-картина соответствует норме.
                        """
                    ),
                    ResearchModelConclusion(
                        date: Date(),
                        model: "medgemma-3-27B",
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
                ]
            ),
            action: {}
        )
        .padding()
    }
}

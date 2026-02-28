import DoglyadUI
import SwiftUI

struct HistoryCard: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let conclusion: USExaminationConclusion
    let action: () -> Void
    private var examinationData: USExaminationData {
        conclusion.examinationData
    }

    var body: some View {
        DButtonCard(
            action: action
        ) {
            HStack(
                spacing: .zero
            ) {
                ZStack {
                    ForEach(Array(examinationData.photos.enumerated()), id: \.element.id) { index, photo in
                        PhotoCard(image: photo.image)
                            .offset(x: Double.random(in: -8 ... 8), y: Double.random(in: -8 ... 8))
                            .rotationEffect(.degrees(Double.random(in: -24 ... 24)))
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
                        DText(examinationData.patientName)
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

                    DText(
                        LocalizedStringResource.forExaminationTypeById(
                            types: container.usExaminationTypesById,
                            id: examinationData.usExaminationTypeId,
                            locale: Locale.current
                        )
                    )
                    .dStyle(
                        font: typography.linkSmall,
                        color: color.grayscalePlacehold
                    )

                    DText(examinationData.examinationDescription)
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
    HistoryCard(
        conclusion: USExaminationConclusion(
            date: Date(),
            neuralModelSettings: NeuralModelSettings(
                selectedNeuralModelId: "google/medgemma-27b-it",
                template: nil,
                responseLength: nil
            ),
            examinationData: USExaminationData(
                usExaminationTypeId: "thyroidGland",
                photos: [
                    USExaminationScanPhoto(image: UIImage(resource: .alertInfo)),
                    USExaminationScanPhoto(image: UIImage(resource: .alertInfo)),
                    USExaminationScanPhoto(image: UIImage(resource: .alertInfo)),
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
                examinationDescription: """
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
                """
            ),
            actualModelConclusion: USExaminationModelConclusion(
                date: Date(),
                modelId: "google/medgemma-27b-it",
                response: """
                Признаков узловых или кистозных изменений щитовидной железы не выявлено.
                Размеры органа в пределах возрастной нормы.
                Эхоструктура паренхимы сохранена, патологических включений нет.
                Данных за воспалительный процесс не получено.
                УЗ-картина соответствует норме.
                """
            ),
            previosModelConclusions: [
                USExaminationModelConclusion(
                    date: Date(),
                    modelId: "google/medgemma-27b-it",
                    response: """
                    Признаков узловых или кистозных изменений щитовидной железы не выявлено.
                    Размеры органа в пределах возрастной нормы.
                    Эхоструктура паренхимы сохранена, патологических включений нет.
                    Данных за воспалительный процесс не получено.
                    УЗ-картина соответствует норме.
                    """
                ),
                USExaminationModelConclusion(
                    date: Date(),
                    modelId: "google/medgemma-27b-it",
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
                ),
            ]
        ),
        action: {}
    )
    .padding()
    .dThemeWrapper()
}

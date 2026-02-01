import DoglyadUI
import Router
import SwiftUI

final class ConclusionScreenArguments: RouteArgumentsProtocol {
    let conclusion: ResearchConclusion

    init(
        conclusion: ResearchConclusion
    ) {
        self.conclusion = conclusion
    }
}

struct ConclusionScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: ConclusionScreenArguments

    var body: some View {
        ConclusionScreenView(
            viewModel: ConclusionViewModel(
                diagnosticRepository: container.diagnosticsRepository,
                router: router,
                initialConclusion: arguments.conclusion
            )
        )
    }
}

private struct ConclusionScreenView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    @StateObject var viewModel: ConclusionViewModel
    var conclusion: ResearchConclusion {
        viewModel.conclusion
    }

    var body: some View {
        DScreen(
            title: .conclusionTitle,
            subTitle: "\(conclusion.data.patientName), \(conclusion.date.localized())",
            onTapBack: viewModel.onTapBack
        ) { toolbarInset in
            ScrollViewReader { proxy in
                ScrollView(
                    showsIndicators: false
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        DText(.forResearchType(conclusion.data.researchType))
                            .dStyle(
                                font: typography.linkLarge
                            )
                            .padding(size.s16)
                            .padding(.horizontal, size.s8)

                        ConclusionPhotosView()

                        VStack(
                            alignment: .leading,
                            spacing: .zero
                        ) {
                            DText(.scanResearchDateLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlaceholder
                                )
                            DText(conclusion.date.localized())
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientNameLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlaceholder
                                )
                            DText(conclusion.data.patientName)
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientGenderLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlaceholder
                                )
                            DText(.forGender(conclusion.data.patientGender))
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanPatientDateOfBirthLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlaceholder
                                )
                            DText(conclusion.data.patientDateOfBirth.localized())
                                .dStyle(
                                    font: typography.textSmall
                                )
                                .padding(.bottom, size.s8)

                            DText(.scanResearchDescriptionLabel)
                                .dStyle(
                                    font: typography.linkSmall,
                                    color: color.grayscalePlaceholder
                                )
                            ExpandableText(
                                text: conclusion.data.researchDescription,
                                backgroundColor: color.grayscaleBackgroundWeak
                            )
                            .padding(.bottom, size.s8)

                            if let patientComplaint = conclusion.data.patientComplaint {
                                DText(.scanPatientComplaintLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlaceholder
                                    )
                                ExpandableText(
                                    text: patientComplaint,
                                    backgroundColor: color.grayscaleBackgroundWeak
                                )
                                .padding(.bottom, size.s8)
                            }

                            if let additionalData = conclusion.data.additionalData {
                                DText(.scanAdditionalDataLabel)
                                    .dStyle(
                                        font: typography.linkSmall,
                                        color: color.grayscalePlaceholder
                                    )
                                ExpandableText(
                                    text: additionalData,
                                    backgroundColor: color.grayscaleBackgroundWeak
                                )
                                .padding(.bottom, size.s8)
                            }

                            DText(.conclusionActualModelResponseTitle)
                                .dStyle(
                                    font: typography.linkLarge
                                )
                                .padding(.top, size.s16)
                                .padding(.horizontal, size.s8)
                                .padding(.bottom, size.s16)
                            ModelConclusionCard(
                                conclusion: conclusion.actualModelConclusion
                            )
                            .padding(.bottom, size.s16)

                            DButton(
                                image: .refresh,
                                title: .buttonRepeatScan,
                                action: {
                                    viewModel.onTapRepeatScan(proxy: proxy)
                                }
                            )
                            .dStyle(.primaryButton)
                            .padding(.bottom, size.s16)

                            if !conclusion.previosModelConclusions.isEmpty {
                                DText(.conclusionPreviosModelResponsesTitle)
                                    .dStyle(
                                        font: typography.linkLarge
                                    )
                                    .padding(.top, size.s8)
                                    .padding(.horizontal, size.s8)
                                    .padding(.bottom, size.s16)
                                ForEach(conclusion.previosModelConclusions) { modelConclusion in
                                    ModelConclusionCard(
                                        conclusion: modelConclusion
                                    )
                                    .padding(.bottom, size.s8)
                                }
                            }
                        }
                        .padding(.top, size.s16 + toolbarInset)
                        .padding(.horizontal, size.s16)
                        .padding(.bottom, size.s128)
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    PreviewWrapperView(
        screenType: .conclusion,
        arguments: ConclusionScreenArguments(
            conclusion: ResearchConclusion(
                date: Date(),
                data: ResearchData(
                    researchType: .thyroidGland,
                    photos: [
                        ResearchScanPhoto(image: UIImage(resource: .alertInfo)),
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
                    """
                ),
                actualModelConclusion: ResearchModelConclusion(
                    date: Date(),
                    model: "google/medgemma-3-27B",
                    response: """
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
                        model: "google/medgemma-3-27B",
                        response: """
                        Признаков узловых или кистозных изменений щитовидной железы не выявлено.
                        Размеры органа в пределах возрастной нормы.
                        Эхоструктура паренхимы сохранена, патологических включений нет.
                        Данных за воспалительный процесс не получено.
                        УЗ-картина соответствует норме.
                        """
                    ),
                    ResearchModelConclusion(
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
                    ),
                ]
            )
        )
    )
}

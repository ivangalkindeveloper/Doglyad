import DoglyadUI
import Router
import SwiftUI

struct ConclusionScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    let arguments: ConclusionScreenArguments

    var body: some View {
        ConclusionScreenView(
            viewModel: ConclusionViewModel(
                container: container,
                messager: messager,
                router: router,
                initialConclusion: arguments.conclusion
            )
        )
    }
}

#Preview {
    ConclusionScreen(
        arguments: ConclusionScreenArguments(
            conclusion: USExaminationConclusion(
                date: Date(),
                neuralModelSettings: NeuralModelSettings(
                    selectedNeuralModelId: "google/medgemma-27b-it",
                    template: nil,
                    responseLength: nil
                ),
                examinationData: USExaminationData(
                    usExaminationTypeId: "abdominalCavity",
                    photos: [
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
            )
        )
    )
    .previewable()
}

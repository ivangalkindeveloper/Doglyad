import DoglyadUI
import Router
import SwiftUI

struct RecievedConclusionBottomSheet: View {
    @Environment(DMessager.self) private var messager
    @EnvironmentObject private var router: DRouter
    let arguments: RecievedConclusionBottomSheetArguments

    var body: some View {
        RecievedConclusionBottomSheetView(
            viewModel: RecievedConclusionViewModel(
                messager: messager,
                router: router,
                arguments: arguments
            )
        )
    }
}

#Preview {
    RecievedConclusionBottomSheet(
        arguments: RecievedConclusionBottomSheetArguments(
            conclusion: USExaminationConclusion(
                date: Date(),
                neuralModelSettings: NeuralModelSettings(
                    selectedNeuralModelId: "google/medgemma-27b-it",
                    temperature: nil,
                    responseLength: nil
                ),
                examinationData: USExaminationData(
                    usExaminationTypeId: "abdominalCavity",
                    photos: [],
                    patientName: "Пациент#0",
                    patientGender: .male,
                    patientDateOfBirth: Date(),
                    patientHeight: 180.0,
                    patientWeight: 80.0,
                    patientComplaint: "Жалобы",
                    examinationDescription: "Описание",
                    additionalData: ""
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
                previosModelConclusions: []
            )
        )
    )
    .background(.black)
    .previewable()
}

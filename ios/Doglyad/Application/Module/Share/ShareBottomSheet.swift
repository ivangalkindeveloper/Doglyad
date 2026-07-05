import DoglyadUI
import Router
import SwiftUI

struct ShareBottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: ShareArguments

    var body: some View {
        ShareBottomSheetView(
            viewModel: ShareViewModel(
                container: container,
                messager: messager,
                router: router,
                arguments: arguments,
                getSendingConclusionByEmailAvailability: { [subscriptionViewModel] in
                    subscriptionViewModel.sendingConclusionByEmailAvailability
                },
                userEmail: ultrasoundViewModel.userEmail
            )
        )
    }
}

#Preview {
    ShareBottomSheet(
        arguments: ShareArguments(
            conclusion: USExaminationConclusion(
                date: Date(),
                neuralModelSettings: NeuralModelSettings(
                    selectedNeuralModelId: "google/medgemma-27b-it",
                    isMarkdown: false,
                    temperature: nil,
                    maxTokens: nil
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
                    response: "УЗ-картина соответствует норме."
                ),
                previosModelConclusions: []
            )
        )
    )
    .previewable()
}

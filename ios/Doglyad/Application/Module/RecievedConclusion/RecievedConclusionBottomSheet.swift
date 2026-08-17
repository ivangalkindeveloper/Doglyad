import DoglyadUI
import Router
import SwiftUI

struct RecievedConclusionBottomSheet: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: RecievedConclusionBottomSheetArguments

    var body: some View {
        RecievedConclusionBottomSheetView(
            viewModel: RecievedConclusionViewModel(
                container: container,
                messager: messager,
                router: router,
                arguments: arguments,
                subscription: subscriptionViewModel,
                userEmail: ultrasoundViewModel.userEmail
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
                    selectedNeuralModelId: "google/medgemma-1.5-4b-it",
                    isMarkdown: false,
                    temperature: nil,
                    maxTokens: nil
                ),
                examinationData: USExaminationData(
                    usExaminationTypeId: "abdominalCavity",
                    photos: [],
                    patientName: "Patient#0",
                    patientGender: .male,
                    patientDateOfBirth: Date(),
                    patientHeight: 180.0,
                    patientWeight: 80.0,
                    patientComplaint: "Patient complaints",
                    examinationDescription: "Examination description"
                ),
                actualModelConclusion: USExaminationModelConclusion(
                    date: Date(),
                    modelId: "google/medgemma-1.5-4b-it",
                    response: """
                    No signs of thyroid nodules or cystic changes were identified.
                    The organ dimensions are within the normal range for age.
                    The parenchymal echotexture is preserved, with no pathological inclusions.
                    No evidence of an inflammatory process was found.
                    The ultrasound findings are within normal limits.
                    """
                ),
                previosModelConclusions: []
            )
        )
    )
    .background(.black)
    .previewable()
}

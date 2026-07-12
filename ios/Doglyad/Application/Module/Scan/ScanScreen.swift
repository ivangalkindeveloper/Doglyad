import DoglyadUI
import Router
import SwiftUI

struct ScanScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    let arguments: ScanScreenArguments?

    var body: some View {
        ScanScreenView(
            viewModel: ScanViewModel(
                container: container,
                messager: messager,
                router: router,
                getTemplateForType: { [ultrasoundViewModel] typeId in
                    ultrasoundViewModel.templateIdByUSExaminationTypeId[typeId]
                },
                refreshSubscriptionStatus: { [subscriptionViewModel] in
                    await subscriptionViewModel.refreshStatus()
                },
                getIsActive: { [subscriptionViewModel] in
                    subscriptionViewModel.isActive
                },
                getAvailableRequestCount: { [subscriptionViewModel] in
                    subscriptionViewModel.availableRequestCount
                },
                getFormCompletionViaMicrophoneAvailability: { [subscriptionViewModel] in
                    subscriptionViewModel.formCompletionViaMicrophoneAvailability
                },
                getNeuralModelSettingsAvailability: { [subscriptionViewModel] in
                    subscriptionViewModel.neuralModelSettingsAvailability
                },
                getNeuralModelSettings: { [subscriptionViewModel] in
                    subscriptionViewModel.neuralModelSettings
                },
                getNeuralModel: { [ultrasoundViewModel] in
                    ultrasoundViewModel.neuralModel
                },
                onNeuralModelSelected: { [ultrasoundViewModel] model in
                    ultrasoundViewModel.saveNeuralModel(model)
                },
                onIncrementRequestCount: { [subscriptionViewModel] in
                    subscriptionViewModel.incrementRequestCount()
                }
            )
        )
    }
}

#Preview {
    ScanScreen(
        arguments: nil
    )
    .previewable()
}

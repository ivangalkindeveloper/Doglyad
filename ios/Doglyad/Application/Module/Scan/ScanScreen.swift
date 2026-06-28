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
                getTemplateForType: { [weak ultrasoundViewModel] typeId in
                    ultrasoundViewModel?.templateIdByUSExaminationTypeId[typeId]
                },
                refreshSubscriptionStatus: { [weak subscriptionViewModel] in
                    await subscriptionViewModel?.refreshStatus()
                },
                getIsActive: { [weak subscriptionViewModel] in
                    subscriptionViewModel?.isActive ?? false
                },
                getFormCompletionViaMicrophoneAvailability: { [weak subscriptionViewModel] in
                    subscriptionViewModel?.formCompletionViaMicrophoneAvailability ?? .unavailable
                },
                getNeuralModelSettings: { [subscriptionViewModel] in
                    subscriptionViewModel.neuralModelSettings
                },
                onIncrementRequestCount: { [weak subscriptionViewModel] in
                    subscriptionViewModel?.incrementRequestCount()
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

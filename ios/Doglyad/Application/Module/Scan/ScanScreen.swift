import DoglyadUI
import Router
import SwiftUI

struct ScanScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
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
                getNeuralModel: { [weak ultrasoundViewModel, container] in
                    ultrasoundViewModel?.neuralModel ?? container.usExaminationNeuralModelDefault
                },
                getIsMarkdown: { [weak ultrasoundViewModel] in
                    ultrasoundViewModel?.isMarkdown ?? false
                },
                getTemperature: { [weak ultrasoundViewModel, container] in
                    ultrasoundViewModel?.temperature
                        ?? container.applicationConfig.ultrasound.defaultNeuralModelTemperature
                },
                getMaxTokens: { [weak ultrasoundViewModel, container] in
                    ultrasoundViewModel?.maxTokens
                        ?? container.applicationConfig.ultrasound.defaultNeuralModelMaxTokens
                },
                getAvailableRequestCount: { [weak ultrasoundViewModel] in
                    ultrasoundViewModel?.availableRequestCount ?? 0
                },
                onIncrementRequestCount: { [weak ultrasoundViewModel] in
                    ultrasoundViewModel?.incrementRequestCount()
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

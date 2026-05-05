import DoglyadUI
import Router
import SwiftUI

struct NeuralModelScreen: View {
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var router: DRouter
    let arguments: NeuralModelScreenArguments?

    var body: some View {
        NeuralModelScreenView(
            viewModel: NeuralModelViewModel(
                initialNeuralModel: ultrasoundViewModel.neuralModel,
                initialIsMarkdown: ultrasoundViewModel.isMarkdown,
                initialTemperature: ultrasoundViewModel.temperature,
                initialMaxTokens: ultrasoundViewModel.maxTokens,
                messager: messager,
                router: router,
                onNeuralModelSelected: { [weak ultrasoundViewModel] model in
                    ultrasoundViewModel?.saveNeuralModel(model)
                },
                onSettingsSaved: { [weak ultrasoundViewModel] isMarkdown, temperature, maxTokens in
                    ultrasoundViewModel?.saveNeuralModelSettings(
                        isMarkdown: isMarkdown,
                        temperature: temperature,
                        maxTokens: maxTokens
                    )
                }
            )
        )
    }
}

#Preview {
    NeuralModelScreen(
        arguments: nil
    )
    .previewable()
}

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
                initialTemperature: ultrasoundViewModel.temperature,
                initialIsMarkdown: ultrasoundViewModel.isMarkdown,
                initialResponseLength: ultrasoundViewModel.responseLength,
                messager: messager,
                router: router,
                onNeuralModelSelected: { [weak ultrasoundViewModel] model in
                    ultrasoundViewModel?.saveNeuralModel(model)
                },
                onSettingsSaved: { [weak ultrasoundViewModel] isMarkdown, temperature, responseLength in
                    ultrasoundViewModel?.saveNeuralModelSettings(
                        isMarkdown: isMarkdown,
                        temperature: temperature,
                        responseLength: responseLength
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

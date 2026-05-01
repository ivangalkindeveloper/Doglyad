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
                initialResponseLength: ultrasoundViewModel.responseLength,
                messager: messager,
                router: router,
                onNeuralModelSelected: { [ultrasoundViewModel] model in
                    ultrasoundViewModel.saveNeuralModel(model)
                },
                onSettingsSaved: { [ultrasoundViewModel] temperature, responseLength in
                    ultrasoundViewModel.saveNeuralModelSettings(
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

import DoglyadUI
import Router
import SwiftUI

struct NeuralModelScreen: View {
    @Environment(DMessager.self) private var messager
    @Environment(UltrasoundViewModel.self) private var ultrasoundViewModel
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

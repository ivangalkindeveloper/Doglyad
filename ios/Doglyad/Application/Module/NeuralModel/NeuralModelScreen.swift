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
                initialTemplate: ultrasoundViewModel.template,
                initialResponseLength: ultrasoundViewModel.responseLength,
                messager: messager,
                router: router,
                onSave: { [ultrasoundViewModel] neuralModel, template, responseLength in
                    ultrasoundViewModel.update(
                        neuralModel: neuralModel,
                        template: template,
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

import DoglyadUI
import Router
import SwiftUI

struct NeuralModelSettingsScreen: View {
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var router: DRouter
    let arguments: NeuralModelSettingsScreenArguments?

    var body: some View {
        NeuralModelSettingsScreenView(
            viewModel: NeuralModelSettingsViewModel(
                initialIsMarkdown: ultrasoundViewModel.isMarkdown,
                initialTemperature: ultrasoundViewModel.temperature,
                initialMaxTokens: ultrasoundViewModel.maxTokens,
                messager: messager,
                router: router,
                onSettingsSaved: { [ultrasoundViewModel] isMarkdown, temperature, maxTokens in
                    ultrasoundViewModel.saveNeuralModelSettings(
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
    NeuralModelSettingsScreen(
        arguments: nil
    )
    .previewable()
}

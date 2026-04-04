import DoglyadUI
import Router
import SwiftUI

struct NeuralModelScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    let arguments: NeuralModelScreenArguments?

    var body: some View {
        NeuralModelScreenView(
            viewModel: NeuralModelViewModel(
                container: container,
                messager: messager,
                router: router
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

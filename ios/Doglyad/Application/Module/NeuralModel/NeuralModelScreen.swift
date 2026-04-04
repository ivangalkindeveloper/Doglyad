import DoglyadUI
import Router
import SwiftUI

struct NeuralModelScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DMessager.self) private var messager
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

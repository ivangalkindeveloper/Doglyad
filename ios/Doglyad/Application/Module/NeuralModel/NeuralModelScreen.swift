import DoglyadUI
import Router
import SwiftUI

struct NeuralModelScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messanger: DMessager
    @EnvironmentObject private var router: DRouter
    let arguments: NeuralModelScreenArguments?

    var body: some View {
        NeuralModelScreenView(
            viewModel: NeuralModelViewModel(
                modelRepository: container.modelRepository,
                messanger: messanger,
                router: router
            )
        )
    }
}

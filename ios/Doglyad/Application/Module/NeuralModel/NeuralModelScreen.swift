import DoglyadUI
import Router
import SwiftUI

final class NeuralModelScreenArguments: RouteArgumentsProtocol {}

struct NeuralModelScreen: View {
    @EnvironmentObject private var router: DRouter
    let arguments: NeuralModelScreenArguments?

    var body: some View {
        NeuralModelScreenView(
            viewModel: NeuralModelViewModel(
                router: router
            )
        )
    }
}

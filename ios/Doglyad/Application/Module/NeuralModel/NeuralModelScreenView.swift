import DoglyadUI
import SwiftUI

struct NeuralModelScreenView: View {
    @StateObject var viewModel: NeuralModelViewModel

    var body: some View {
        DScreen(
            title: .settingsNeuralModelTitle,
            onTapBack: viewModel.onTapBack
        ) { _ in
            Color.clear
        }
    }
}

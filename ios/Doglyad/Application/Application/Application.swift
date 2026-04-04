import DoglyadUI
import SwiftData
import SwiftUI

@main
struct Application: App {
    @State private var viewModel = ApplicationViewModel()

    var body: some Scene {
        WindowGroup {
            AnyView(
                self.viewModel.root
            )
            .onAppear {
                self.viewModel.initialize()
            }
            .dThemeWrapper()
            .environment(viewModel)
        }
    }
}

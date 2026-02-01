import DoglyadUI
import SwiftData
import SwiftUI

@main
struct Application: App {
    @StateObject private var viewModel = ApplicationViewModel()

    var body: some Scene {
        WindowGroup {
            ApplicationWrapperView(
                viewModel: viewModel
            ) {
                DThemeWrapperView {
                    AnyView(
                        self.viewModel.root
                    )
                    .onAppear {
                        self.viewModel.initialize()
                    }
                }
            }
        }
    }
}

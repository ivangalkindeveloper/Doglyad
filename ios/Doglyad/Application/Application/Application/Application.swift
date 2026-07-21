import DoglyadUI
import SwiftData
import SwiftUI

@main
struct Application: App {
    @StateObject private var viewModel = ApplicationViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AnyView(
                    self.viewModel.root
                )
                .id(self.viewModel.rootID)
                .transition(
                    .asymmetric(
                        insertion: .opacity,
                        removal: .opacity
                    )
                )
            }
            .animation(
                .easeInOut(duration: 0.35),
                value: self.viewModel.rootID
            )
            .onAppear {
                self.viewModel.initialize()
            }
            .dThemeWrapper()
            .environmentObject(viewModel)
        }
    }
}

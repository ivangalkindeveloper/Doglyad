import SwiftUI
import SwiftData
import DoglyadUI



@main
struct Application: App {
    init() {
        DFontRegister.registerFonts(
            bundle: Bundle(for: InitializationProcess.self)
        )
    }
    
    @StateObject private var viewModel = ApplicationViewModel()

    var body: some Scene {
        WindowGroup {
            ApplicationWrapperView(
                viewModel: viewModel,
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



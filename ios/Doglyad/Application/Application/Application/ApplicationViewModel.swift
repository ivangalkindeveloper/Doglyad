import DependencyInitializer
import SwiftUI

@MainActor
final class ApplicationViewModel: DViewModel {
    // Reproduce the native launch screen geometry exactly (`LaunchScreen.storyboard`):
    // a white background and a `scaleAspectFill` image stretched to every screen edge
    // and centred on it. Without an explicit full-screen container SwiftUI centres the
    // image on the safe area (whose centre sits below the screen centre because the top
    // inset is larger), which made the SwiftUI splash drift down from the native one.
    @Published var root: any View = Color.white
        .overlay {
            Image(.splash)
                .resizable()
                .scaledToFill()
        }
        .ignoresSafeArea()
    @Published var rootID = UUID()
    @Published var isLoading = false

    @MainActor
    func initialize() {
        isLoading = true
        Task {
            await DependencyInitializer<InitializationProcess, DependencyContainer>(
                createProcess: { InitializationProcess() },
                stepSets: [
                    InitializationProcess.stepsTier1,
                    InitializationProcess.stepsTier2,
                    InitializationProcess.stepsTier3,
                    InitializationProcess.stepsTier4,
                ],
                onSuccess: { [weak self] result, _ in
                    guard let self = self else { return }

                    self.isLoading = false
                    self.root = MainRootView(
                        dependencyContainer: result.container
                    )
                    self.rootID = UUID()
                },
                onError: { [weak self] error, _, _, _ in
                    guard let self = self else { return }

                    self.isLoading = false
                    self.root = ErrorRootView(
                        error: error
                    )
                    self.rootID = UUID()
                }
            ).run()
        }
    }

    func openSettings() {
        UIApplication.openSettings()
    }
}

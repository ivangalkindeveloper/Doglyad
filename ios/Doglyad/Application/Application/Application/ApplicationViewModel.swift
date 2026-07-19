import DependencyInitializer
import SwiftUI

@MainActor
final class ApplicationViewModel: DViewModel {
    @Published var root: any View = EmptyView()
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
                },
                onError: { [weak self] error, _, _, _ in
                    guard let self = self else { return }

                    self.isLoading = false
                    self.root = ErrorRootView(
                        error: error
                    )
                }
            ).run()
        }
    }

    func openSettings() {
        UIApplication.openSettings()
    }
}

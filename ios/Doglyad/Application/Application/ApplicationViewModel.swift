import DependencyInitializer
import SwiftUI

final class ApplicationViewModel: ObservableObject {
    @Published var root: any View = EmptyView()
    @Published var isLoading = false

    @MainActor
    func initialize() {
        isLoading = true
        Task {
            await DependencyInitializer<InitializationProcess, DependencyContainer>(
                createProcess: { InitializationProcess() },
                preSyncSteps: InitializationProcess.preSyncSteps,
                asyncSteps: InitializationProcess.asyncSteps,
                postSyncSteps: InitializationProcess.postSyncSteps,
                onStartStep: { step in
                    print(step.title ?? "")
                },
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

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
                    StepSet(sync: InitializationProcess.preSyncSteps),
                    StepSet(async: InitializationProcess.firstAsyncSteps),
                    StepSet(async: InitializationProcess.secondAsyncSteps),
                    StepSet(sync: InitializationProcess.postSyncSteps),
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

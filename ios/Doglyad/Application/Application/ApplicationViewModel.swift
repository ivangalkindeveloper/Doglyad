import SwiftUI
import DependencyInitializer

final class ApplicationViewModel: ObservableObject {
    @Published var root: any View = EmptyView()
    @Published var isLoading = false

    @MainActor
    func initialize() -> Void {
        self.isLoading = true
        DependencyInitializer<InitializationProcess, DependencyContainer>(
            createProcess: {
                InitializationProcess()
            },
            steps: InitializationProcess.steps,
            onSuccess: { [weak self] result, _ in
                guard let self = self else { return }
                
                self.isLoading = false
                self.root = MainRootView(
                    dependencyContainer: result.container,
                )
            },
            onError: { [weak self] error, _, _, _ in
                guard let self = self else { return }
                
                self.isLoading = false
                self.root = ErrorRootView(
                    error: error,
                )
            }
        ).run()
    }
    
    func openSettings() -> Void {
        UIApplication.openSettings()
    }
}

import DependencyInitializer
import SwiftUI

@MainActor
final class ApplicationViewModel: DViewModel {
    // Полностью повторяем геометрию нативного лаунч-скрина (`Launch Screen.storyboard`):
    // белый фон и `scaleAspectFill`-картинка, растянутая по всем краям экрана и
    // отцентрованная по нему. Без явного полноэкранного контейнера SwiftUI центрует
    // картинку по safe area (её центр ниже центра экрана из-за большего верхнего
    // отступа), из-за чего сплеш на вью «съезжал» вниз относительно нативного.
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

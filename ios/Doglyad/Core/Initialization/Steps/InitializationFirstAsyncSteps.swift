import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let firstAsyncSteps: [AsyncInitializationStep<InitializationProcess>] = [
        AsyncInitializationStep<InitializationProcess>(
            title: "Permission",
            run: { (process: InitializationProcess) in
                let isGranted = await process.permissionManager!.isGranted(.camera)
                if !isGranted {
                    throw InitializationError.noCameraRequestDenied
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Application config",
            run: { (process: InitializationProcess) async throws in
                do {
                    let url = await process.environment!.configUrl
                    let applicationConfig: ApplicationConfig = try await process.httpClient!.get(url: url)
                    await MainActor.run {
                        process.applicationConfig = applicationConfig
                    }
                } catch {
                    print(error)
                }
            }
        ),
    ]
}

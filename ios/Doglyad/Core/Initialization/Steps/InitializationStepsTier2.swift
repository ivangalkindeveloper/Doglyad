import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let stepsTier2 = StepSet(
        async: [
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
                    // Config comes from the backend, not from the repository, so the
                    // app and the backend cannot disagree about which models exist.
                    // Outside the `/v1` prefix: these documents are public and are
                    // read before there is anything to authenticate with.
                    let url = await process.environment!.baseUrl.appendingPathComponent("application_config")
                    let applicationConfig: ApplicationConfig = try await process.httpClient!.get(url: url)
                    await MainActor.run {
                        process.applicationConfig = applicationConfig
                    }
                }
            ),
        ]
    )
}

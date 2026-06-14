import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let stepsTier3 = StepSet(
        async: [
            AsyncInitializationStep<InitializationProcess>(
                title: "Application config",
                run: { (process: InitializationProcess) async throws in
                    let url = await process.environment!.configUrl
                    let applicationConfig: ApplicationConfig = try await process.httpClient!.get(url: url)
                    await MainActor.run {
                        process.applicationConfig = applicationConfig
                    }
                }
            ),
        ]
    )
}

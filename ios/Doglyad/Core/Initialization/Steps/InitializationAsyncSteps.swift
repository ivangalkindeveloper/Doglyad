import DependencyInitializer
import DoglyadNeuralModel

extension InitializationProcess {
    static let asyncSteps: [AsyncInitializationStep<InitializationProcess>] = [
        AsyncInitializationStep<InitializationProcess>(
            title: "Permission",
            run: { (process: InitializationProcess) -> Void in
                let isGranted = await process.permissionmanager!.isGranted(.camera)
                if !isGranted {
                    throw InitializationError.noCameraRequestDenied
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Application config",
            run: { (process: InitializationProcess) async -> Void in
                do {
                    let configUrl = await process.environment!.contentUrl
                        .appendingPathComponent("config")
                        .appendingPathComponent("application.json")
                    let applicationConfig: ApplicationConfig = try await process.httpClient!.get(url: configUrl)
                    await MainActor.run {
                        process.applicationConfig = applicationConfig
                    }
                } catch {
                    await MainActor.run {
                        process.applicationConfig = .default
                    }
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Research Neural Model",
            run: { (process: InitializationProcess) -> Void in
                if #available(iOS 26.0, *), DResearchNeuralModelFoundationModels.isAvailable {
                    return await MainActor.run {
                        process.researchNeuralModel = DResearchNeuralModelFoundationModels()
                    }
                }
                if DResearchNeuralModelMLX.isAvailable {
                    let model = try await DResearchNeuralModelMLX()
                    return await MainActor.run {
                        process.researchNeuralModel = model
                    }
                }
            }
        ),
    ]
}

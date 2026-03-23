import DependencyInitializer
import DoglyadNeuralModel
import Foundation

extension InitializationProcess {
    static let asyncSteps: [AsyncInitializationStep<InitializationProcess>] = [
        AsyncInitializationStep<InitializationProcess>(
            title: "Permission",
            run: { (process: InitializationProcess) in
                let isGranted = await process.permissionmanager!.isGranted(.camera)
                if !isGranted {
                    throw InitializationError.noCameraRequestDenied
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Application config",
            run: { (process: InitializationProcess) async in
                do {
                    let url = await process.environment!.contentUrl
                        .appendingPathComponent(process.environment!.contentConfigPathPrefix + "/application.json")
                    let applicationConfig: ApplicationConfig = try await process.httpClient!.get(url: url)
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
            title: "Ultrasound examination types",
            run: { (process: InitializationProcess) async throws in
                let url = await process.environment!.contentUrl
                    .appendingPathComponent(process.environment!.contentConfigPathPrefix + "/ultrasound_examination_types.json")
                let usExaminationTypes: [USExaminationType] = try await process.httpClient!.get(url: url)
                if usExaminationTypes.isEmpty {
                    throw InitializationError.usExaminationTypesEmpty
                }

                await MainActor.run {
                    process.usExaminationTypes = usExaminationTypes
                    process.usExaminationTypesById = Dictionary(
                        uniqueKeysWithValues: usExaminationTypes.map { ($0.id, $0) }
                    )
                    process.usExaminationTypeDefault = usExaminationTypes.first!
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Ultrasound examination neural models",
            run: { (process: InitializationProcess) async throws in
                let url = await process.environment!.contentUrl
                    .appendingPathComponent(process.environment!.contentConfigPathPrefix + "/ultrasound_examination_neural_models.json")
                let usExaminationNeuralModels: [USExaminationNeuralModel] = try await process.httpClient!.get(url: url)
                if usExaminationNeuralModels.isEmpty {
                    throw InitializationError.usExaminationNeuralModelsEmpty
                }

                await MainActor.run {
                    process.usExaminationNeuralModels = usExaminationNeuralModels
                    process.usExaminationNeuralModelsById = Dictionary(
                        uniqueKeysWithValues: usExaminationNeuralModels.map { ($0.id, $0) }
                    )
                    process.usExaminationNeuralModelDefault = usExaminationNeuralModels.first!
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Local ultrasound examination neural model",
            run: { (process: InitializationProcess) in
                if #available(iOS 26.0, *), DExaminationNeuralModelFoundationModels.isAvailable {
                    return await MainActor.run {
                        process.examinationNeuralModel = DExaminationNeuralModelFoundationModels()
                    }
                }
                if DExaminationNeuralModelMLX.isAvailable {
                    let model = try await DExaminationNeuralModelMLX()
                    return await MainActor.run {
                        process.examinationNeuralModel = model
                    }
                }
            }
        ),
    ]
}

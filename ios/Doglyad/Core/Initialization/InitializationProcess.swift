import AVFoundation
import DependencyInitializer
import DoglyadDatabase
import DoglyadNetwork
import DoglyadNeuralModel
import FirebaseCore
import Foundation
import FoundationModels
import Router
import SwiftData

@MainActor
final class InitializationProcess: DependencyInitializationProcess {
    typealias T = DependencyContainer

    var environment: EnvironmentProtocol?
    var applicationConfig: ApplicationConfig?
    var researchNeuralModel: DResearchNeuralModelProtocol?
    var connectionManager: ConnectionManagerProtocol?
    var permissionmanager: PermissionManagerProtocol?
    var database: DDatabase?
    var httpClient: DHttpClientProtocol?
    var sharedRepository: SharedRepositoryProtocol?
    var modelRepository: ModelRepositoryProtocol?
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    var researchTypes: [ResearchType]?
    var initialScreen: ScreenType?
    var initialScreenArguments: RouteArgumentsProtocol?

    var toContainer: DependencyContainer {
        DependencyContainer(
            environment: environment!,
            applicationConfig: applicationConfig!,
            researchNeuralModel: researchNeuralModel,
            connectionManager: connectionManager!,
            permissionmanager: permissionmanager!,
            sharedRepository: sharedRepository!,
            modelRepository: modelRepository!,
            diagnosticsRepository: diagnosticsRepository!,
            researchTypes: researchTypes!,
            initialScreen: initialScreen!,
            initialScreenArguments: initialScreenArguments
        )
    }
}

extension InitializationProcess {
    static let steps: [DependencyInitializationStep] = [
        InitializationStep<InitializationProcess>(
            title: "Environment",
            run: { (process: InitializationProcess) -> Void in
                let baseUrlSchemaString = Bundle.dictionaryString(.BASE_URL_SCHEMA)
                let baseUrlString = Bundle.dictionaryString(.BASE_URL)
                let baseUrl = URL(string: "\(baseUrlSchemaString)://\(baseUrlString)")!
                process.environment = EnvironmentBase(
                    baseUrl: baseUrl
                )
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
        InitializationStep<InitializationProcess>(
            title: "Manager",
            run: { (process: InitializationProcess) -> Void in
                process.connectionManager = ConnectionManager()
                process.connectionManager?.start()
                process.permissionmanager = PermissionManager()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Database",
            run: { (process: InitializationProcess) -> Void in
                process.database = try DDatabase()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "HttpClient",
            run: { (process: InitializationProcess) -> Void in
                process.httpClient = DHttpClient(
                    baseUrl: process.environment!.baseUrl.absoluteString
                )
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Repository",
            run: { (process: InitializationProcess) -> Void in
                process.sharedRepository = SharedRepository(
                    database: process.database!
                )
                process.modelRepository = ModelRepository(
                    database: process.database!
                )
                process.diagnosticsRepository = DiagnosticsRepository(
                    database: process.database!,
                    httpClient: process.httpClient!
                )
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Firebase",
            run: { (process: InitializationProcess) -> Void in
                FirebaseApp.configure()
            }
        ),

        InitializationStep<InitializationProcess>(
            title: "Internet connection",
            run: { (process: InitializationProcess) -> Void in
                let isConnected = process.connectionManager!.isConnected
                if !isConnected {
                    throw InitializationError.noInternetConnection
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Permission",
            run: { (process: InitializationProcess) -> Void in
                let isGranted = await process.permissionmanager!.isGranted(.camera)
                if !isGranted {
                    throw InitializationError.noCameraRequestDenied
                }
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Research types",
            run: { (process: InitializationProcess) -> Void in
                process.researchTypes = ResearchType.allCases
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Initial screen",
            run: { (process: InitializationProcess) -> Void in
                if Bundle.shortVersion.major < process.applicationConfig!.actualVersion.major && process.applicationConfig?.appStoreId != nil {
                    return process.initialScreen = .newVersion
                }
                
                let isOnBoardingCompleted = process.database!.getOnBoardingCompleted()
                let selectedUSResearchType = process.database!.getSelectedUSResearchType()
                if isOnBoardingCompleted, selectedUSResearchType != nil {
                    return process.initialScreen = .scan
                }
                process.initialScreen = .onBoarding
            }
        ),
    ]
}

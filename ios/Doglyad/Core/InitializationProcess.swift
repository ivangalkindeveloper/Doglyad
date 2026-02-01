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
    var researchNeuralModel: DResearchNeuralModelProtocol?
    var connectionManager: ConnectionManagerProtocol?
    var permissionmanager: PermissionManagerProtocol?
    var database: DDatabase?
    var httpClient: DHttpClientProtocol?
    var sharedRepository: SharedRepositoryProtocol?
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    var researchTypes: [ResearchType]?
    var initialScreen: ScreenType?
    var initialScreenArguments: RouteArgumentsProtocol?

    var toContainer: DependencyContainer {
        DependencyContainer(
            environment: environment!,
            researchNeuralModel: researchNeuralModel,
            connectionManager: connectionManager!,
            permissionmanager: permissionmanager!,
            sharedRepository: sharedRepository!,
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
            run: { process in
                let baseUrlSchemaString = Bundle.dictionaryString(.BASE_URL_SCHEMA)
                let baseUrlString = Bundle.dictionaryString(.BASE_URL)
                let baseUrl = URL(string: "\(baseUrlSchemaString)://\(baseUrlString)")!
                process.environment = EnvironmentBase(
                    baseURL: baseUrl
                )
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Research Neural Model",
            run: { process in
//                if #available(iOS 26.0, *), DResearchNeuralModelFoundationModels.isAvailable {
//                    process.researchNeuralModel = DResearchNeuralModelFoundationModels()
//                    return
//                }
//                if DResearchNeuralModelMLX.isAvailable {
//                    process.researchNeuralModel = await DResearchNeuralModelMLX()
//                    return
//                }

                let model = try await DResearchNeuralModelMLX()
                await MainActor.run {
                    process.researchNeuralModel = model
                }
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Manager",
            run: { process in
                process.connectionManager = ConnectionManager()
                process.connectionManager?.start()
                process.permissionmanager = PermissionManager()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Database",
            run: { process in
                process.database = try DDatabase()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "HttpClient",
            run: { process in
                process.httpClient = DHttpClient(
                    baseUrl: process.environment!.baseURL.absoluteString
                )
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Repository",
            run: { process in
                process.sharedRepository = SharedRepository(
                    database: process.database!
                )
                process.diagnosticsRepository = DiagnosticsRepository(
                    database: process.database!,
                    httpClient: process.httpClient!
                )
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Internet connection",
            run: { process in
                let isConnected = process.connectionManager!.isConnected
                if !isConnected {
                    throw InitializationError.noInternetConnection
                }
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Permission",
            run: { process in
                let isGranted = await process.permissionmanager!.isGranted(.camera)
                if !isGranted {
                    throw InitializationError.noCameraRequestDenied
                }
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Research types",
            run: { process in
                process.researchTypes = ResearchType.allCases
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Initial screen",
            run: { process in
                let isOnBoardingCompleted = process.database!.getOnBoardingCompleted()
                let selectedUSResearchType = process.database!.getSelectedUSResearchType()
                if isOnBoardingCompleted, selectedUSResearchType != nil {
                    process.initialScreen = .scan
                } else {
                    process.initialScreen = .onBoarding
                }
                process.initialScreenArguments = nil
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Firebase",
            run: { _ in
                FirebaseApp.configure()
            }
        ),
    ]
}

import Foundation
import SwiftData
import DependencyInitializer
import AVFoundation
import DoglyadDB
import Router

@MainActor
final class InitializationProcess: DependencyInitializationProcess {
    typealias T = DependencyContainer
    
    var environment: EnvironmentProtocol?

    var connectionManager: ConnectionManagerProtocol?
    var permissionmanager: PermissionManagerProtocol?
    
    var database: DDatabase?
    
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    
    var researchTypes: [ResearchType]?
    
    var initialScreen: ScreenType?
    var initialScreenArguments: RouteArgumentsProtocol?
    
    var toContainer: DependencyContainer {
        get {
            DependencyContainer(
                environment: self.environment!,
                diagnosticsRepository: self.diagnosticsRepository!,
                researchTypes: self.researchTypes!,
                initialScreen: self.initialScreen!,
                initialScreenArguments: self.initialScreenArguments,
            )
        }
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
        InitializationStep<InitializationProcess>(
            title: "Manager",
            run: { process in
                process.connectionManager = ConnectionManager()
                process.connectionManager?.start()
                process.permissionmanager = PermissionManager()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "ModelContainer",
            run: { process in
                process.database = try DDatabase()
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Repository",
            run: { process in
                process.diagnosticsRepository = DiagnosticsRepository(
                    database: process.database!
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
                process.researchTypes = [
                    .thyroidGland
                ]
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "Initial screen",
            run: { process in
                let isOnBoardingCompleted = process.database!.getOnBoardingCompleted()
                let selectedUSResearchType = process.database!.getSelectedUSResearchType()
                if isOnBoardingCompleted && selectedUSResearchType != nil {
                    process.initialScreen = .scan
                } else {
                    process.initialScreen = .onBoarding
                }
                process.initialScreenArguments = nil
            }
        ),
    ]
}

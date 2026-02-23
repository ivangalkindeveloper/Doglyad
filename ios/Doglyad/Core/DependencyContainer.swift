import DoglyadDatabase
import DoglyadNetwork
import DoglyadNeuralModel
import Router
import SwiftData
import SwiftUI

final class DependencyContainer: ObservableObject {
    let environment: EnvironmentProtocol
    let connectionManager: ConnectionManagerProtocol
    let permissionmanager: PermissionManagerProtocol
    let sharedRepository: SharedRepositoryProtocol
    let modelRepository: ModelRepositoryProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let applicationConfig: ApplicationConfig
    let researchNeuralModel: DResearchNeuralModelProtocol?
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?

    init(
        environment: EnvironmentProtocol,
        connectionManager: ConnectionManagerProtocol,
        permissionmanager: PermissionManagerProtocol,
        sharedRepository: SharedRepositoryProtocol,
        modelRepository: ModelRepositoryProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        applicationConfig: ApplicationConfig,
        researchNeuralModel: DResearchNeuralModelProtocol?,
        researchTypes: [ResearchType],
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?
    ) {
        self.environment = environment
        self.connectionManager = connectionManager
        self.permissionmanager = permissionmanager
        self.sharedRepository = sharedRepository
        self.modelRepository = modelRepository
        self.diagnosticsRepository = diagnosticsRepository
        self.applicationConfig = applicationConfig
        self.researchNeuralModel = researchNeuralModel
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }

    var isResearchNeuralModelAvailable: Bool { researchNeuralModel != nil }
}

extension DependencyContainer {
    static var previewable: DependencyContainer {
        let environment = EnvironmentBase(
            baseUrl: URL(filePath: "")!
        )
        let database = try! DDatabase()
        let httpClient = DHttpClient(
            baseUrl: environment.baseUrl.absoluteString
        )
        let sharedRepository = SharedRepository(
            database: database
        )
        let modelRepository = ModelRepository(
            database: database
        )
        let diagnosticsRepository = DiagnosticsRepository(
            database: database,
            httpClient: httpClient
        )

        return DependencyContainer(
            environment: environment,
            connectionManager: ConnectionManager(),
            permissionmanager: PermissionManager(),
            sharedRepository: sharedRepository,
            modelRepository: modelRepository,
            diagnosticsRepository: diagnosticsRepository,
            applicationConfig: .default,
            researchNeuralModel: nil,
            researchTypes: ResearchType.allCases,
            initialScreen: .onBoarding,
            initialScreenArguments: nil
        )
    }
}

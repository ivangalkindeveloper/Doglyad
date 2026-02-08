import DoglyadDatabase
import DoglyadNetwork
import DoglyadNeuralModel
import Router
import SwiftData
import SwiftUI

func previewableContainer(
    screenType: ScreenType,
    arguments: RouteArgumentsProtocol?
) -> DependencyContainer {
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
        researchNeuralModel: nil,
        connectionManager: ConnectionManager(),
        permissionmanager: PermissionManager(),
        sharedRepository: sharedRepository,
        modelRepository: modelRepository,
        diagnosticsRepository: diagnosticsRepository,
        researchTypes: ResearchType.allCases,
        initialScreen: screenType,
        initialScreenArguments: arguments
    )
}

final class DependencyContainer: ObservableObject {
    let environment: EnvironmentProtocol
    let researchNeuralModel: DResearchNeuralModelProtocol?
    let connectionManager: ConnectionManagerProtocol
    let permissionmanager: PermissionManagerProtocol
    let sharedRepository: SharedRepositoryProtocol
    let modelRepository: ModelRepositoryProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?

    init(
        environment: EnvironmentProtocol,
        researchNeuralModel: DResearchNeuralModelProtocol?,
        connectionManager: ConnectionManagerProtocol,
        permissionmanager: PermissionManagerProtocol,
        sharedRepository: SharedRepositoryProtocol,
        modelRepository: ModelRepositoryProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        researchTypes: [ResearchType],
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?
    ) {
        self.environment = environment
        self.researchNeuralModel = researchNeuralModel
        self.connectionManager = connectionManager
        self.permissionmanager = permissionmanager
        self.sharedRepository = sharedRepository
        self.modelRepository = modelRepository
        self.diagnosticsRepository = diagnosticsRepository
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }

    var isResearchNeuralModelAvailable: Bool { researchNeuralModel != nil }
}

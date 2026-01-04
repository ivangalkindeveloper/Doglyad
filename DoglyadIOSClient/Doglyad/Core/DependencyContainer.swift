import SwiftUI
import SwiftData
import DoglyadDB
import DoglyadML
import Router

func previewableContainer(
    screenType: ScreenType,
    arguments: RouteArgumentsProtocol?
) -> DependencyContainer {
    let environment = EnvironmentBase(baseURL: URL(filePath: "")!)
    let datebase = try! DDatabase()
    let diagnosticsRepository = DiagnosticsRepository(database: datebase)
    
    return DependencyContainer(
        environment: environment,
        researchNeuralModel: nil,
        connectionManager: ConnectionManager(),
        permissionmanager: PermissionManager(),
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
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?
    
    init(
        environment: EnvironmentProtocol,
        researchNeuralModel: DResearchNeuralModelProtocol?,
        connectionManager: ConnectionManagerProtocol,
        permissionmanager: PermissionManagerProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        researchTypes: [ResearchType],
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?,
    ) {
        self.environment = environment
        self.researchNeuralModel = researchNeuralModel
        self.connectionManager = connectionManager
        self.permissionmanager = permissionmanager
        self.diagnosticsRepository = diagnosticsRepository
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }
    
    var isResearchNeuralModelAvailable: Bool { researchNeuralModel != nil }
}

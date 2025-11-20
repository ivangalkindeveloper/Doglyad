import SwiftUI
import SwiftData
import DoglyadDB
import Router

final class DependencyContainer: ObservableObject {
    static func previewable(
        screenType: ScreenType,
        arguments: RouteArgumentsProtocol?
    ) -> DependencyContainer {
        let environment = EnvironmentBase(baseURL: URL(filePath: "")!)
        let datebase = try! DDatabase()
        let diagnosticsRepository = DiagnosticsRepository(database: datebase)
        
        return DependencyContainer(
            environment: environment,
            connectionManager: ConnectionManager(),
            permissionmanager: PermissionManager(),
            diagnosticsRepository: diagnosticsRepository,
            researchTypes: ResearchType.allCases,
            initialScreen: screenType,
            initialScreenArguments: arguments
        )
    }
    
    let environment: EnvironmentProtocol
    let connectionManager: ConnectionManagerProtocol
    let permissionmanager: PermissionManagerProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?
    
    init(
        environment: EnvironmentProtocol,
        connectionManager: ConnectionManagerProtocol,
        permissionmanager: PermissionManagerProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        researchTypes: [ResearchType],
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?,
    ) {
        self.environment = environment
        self.connectionManager = connectionManager
        self.permissionmanager = permissionmanager
        self.diagnosticsRepository = diagnosticsRepository
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }
}

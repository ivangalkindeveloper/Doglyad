import DependencyInitializer
import Router
import DoglyadNeuralModel
import DoglyadNetwork
import DoglyadDatabase

@MainActor
final class InitializationProcess: DependencyInitializationProcess {
    typealias T = DependencyContainer

    var environment: EnvironmentProtocol?
    var connectionManager: ConnectionManagerProtocol?
    var permissionmanager: PermissionManagerProtocol?
    var database: DDatabase?
    var httpClient: DHttpClientProtocol?
    var sharedRepository: SharedRepositoryProtocol?
    var modelRepository: ModelRepositoryProtocol?
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    var applicationConfig: ApplicationConfig?
    var researchNeuralModel: DResearchNeuralModelProtocol?
    var researchTypes: [ResearchType]?
    var initialScreen: ScreenType?
    var initialScreenArguments: RouteArgumentsProtocol?

    var toContainer: DependencyContainer {
        DependencyContainer(
            environment: environment!,
            connectionManager: connectionManager!,
            permissionmanager: permissionmanager!,
            sharedRepository: sharedRepository!,
            modelRepository: modelRepository!,
            diagnosticsRepository: diagnosticsRepository!,
            applicationConfig: applicationConfig!,
            researchNeuralModel: researchNeuralModel,
            researchTypes: researchTypes!,
            initialScreen: initialScreen!,
            initialScreenArguments: initialScreenArguments
        )
    }
}

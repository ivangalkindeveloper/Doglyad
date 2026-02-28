import DependencyInitializer
import DoglyadDatabase
import DoglyadNetwork
import DoglyadNeuralModel
import Router

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
    var usExaminationTypes: [USExaminationType]?
    var usExaminationTypesById: [String: USExaminationType]?
    var usExaminationNeuralModels: [USExaminationNeuralModel]?
    var usExaminationNeuralModelsById: [String: USExaminationNeuralModel]?
    var examinationNeuralModel: DExaminationNeuralModelProtocol?
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
            usExaminationTypes: usExaminationTypes!,
            usExaminationTypesById: usExaminationTypesById!,
            usExaminationNeuralModels: usExaminationNeuralModels!,
            usExaminationNeuralModelsById: usExaminationNeuralModelsById!,
            examinationNeuralModel: examinationNeuralModel,
            initialScreen: initialScreen!,
            initialScreenArguments: initialScreenArguments
        )
    }
}

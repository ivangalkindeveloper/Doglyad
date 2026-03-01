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
    var usExaminationRepository: USExaminationRepositoryProtocol?
    var applicationConfig: ApplicationConfig?
    var usExaminationTypes: [USExaminationType]?
    var usExaminationTypesById: [String: USExaminationType]?
    var usExaminationTypeDefault: USExaminationType?
    var usExaminationNeuralModels: [USExaminationNeuralModel]?
    var usExaminationNeuralModelsById: [String: USExaminationNeuralModel]?
    var usExaminationNeuralModelDefault: USExaminationNeuralModel?
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
            usExaminationRepository: usExaminationRepository!,
            applicationConfig: applicationConfig!,
            usExaminationTypes: usExaminationTypes!,
            usExaminationTypesById: usExaminationTypesById!,
            usExaminationTypeDefault: usExaminationTypeDefault!,
            usExaminationNeuralModels: usExaminationNeuralModels!,
            usExaminationNeuralModelsById: usExaminationNeuralModelsById!,
            usExaminationNeuralModelDefault: usExaminationNeuralModelDefault!,
            examinationNeuralModel: examinationNeuralModel,
            initialScreen: initialScreen!,
            initialScreenArguments: initialScreenArguments
        )
    }
}

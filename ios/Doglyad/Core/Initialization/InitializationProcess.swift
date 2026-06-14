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
    var permissionManager: PermissionManagerProtocol?
    var database: DDatabase?
    var httpClient: DHttpClientProtocol?
    var sharedRepository: SharedRepositoryProtocol?
    var userSettingsRepository: UserSettingsRepositoryProtocol?
    var ultrasoundModelRepository: UltrasoundModelRepositoryProtocol?
    var ultrasoundConclusionRepository: UltrasoundConclusionRepositoryProtocol?
    var templateRepository: TemplateRepositoryProtocol?
    var subscriptionRepository: RevenueCatSubscriptionRepository?
    var applicationConfig: ApplicationConfig?
    var usExaminationTypes: [USExaminationType]?
    var usExaminationTypesById: [String: USExaminationType]?
    var usExaminationTypeDefault: USExaminationType?
    var usExaminationNeuralModels: [USExaminationNeuralModel]?
    var usExaminationNeuralModelsById: [String: USExaminationNeuralModel]?
    var usExaminationNeuralModelDefault: USExaminationNeuralModel?
    var examinationNeuralModel: DExaminationNeuralModelProtocol?
    var initialUltraSoundConclusions: [USExaminationConclusion]?
    var initialSubscriptionStatus: SubscriptionStatus?
    var initialRemainingRequestCount: Int?
    var initialScreen: ScreenType?
    var initialScreenArguments: RouteArgumentsProtocol?

    var toContainer: DependencyContainer {
        DependencyContainer(
            environment: environment!,
            connectionManager: connectionManager!,
            permissionManager: permissionManager!,
            sharedRepository: sharedRepository!,
            userSettingsRepository: userSettingsRepository!,
            ultrasoundModelRepository: ultrasoundModelRepository!,
            ultrasoundConclusionRepository: ultrasoundConclusionRepository!,
            templateRepository: templateRepository!,
            subscriptionRepository: subscriptionRepository!,
            applicationConfig: applicationConfig!,
            usExaminationTypes: usExaminationTypes!,
            usExaminationTypesById: usExaminationTypesById!,
            usExaminationTypeDefault: usExaminationTypeDefault!,
            usExaminationNeuralModels: usExaminationNeuralModels!,
            usExaminationNeuralModelsById: usExaminationNeuralModelsById!,
            usExaminationNeuralModelDefault: usExaminationNeuralModelDefault!,
            examinationNeuralModel: examinationNeuralModel,
            initialSubscriptionStatus: initialSubscriptionStatus,
            initialRemainingRequestCount: initialRemainingRequestCount!,
            initialScreen: initialScreen!,
            initialScreenArguments: initialScreenArguments
        )
    }
}

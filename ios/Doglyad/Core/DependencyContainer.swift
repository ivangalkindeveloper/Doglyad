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
    let usExaminationRepository: USExaminationRepositoryProtocol
    let applicationConfig: ApplicationConfig
    let examinationNeuralModel: DExaminationNeuralModelProtocol?
    let usExaminationTypes: [USExaminationType]
    let usExaminationTypesById: [String: USExaminationType]
    let usExaminationTypeDefault: USExaminationType
    let usExaminationNeuralModels: [USExaminationNeuralModel]
    let usExaminationNeuralModelsById: [String: USExaminationNeuralModel]
    let usExaminationNeuralModelDefault: USExaminationNeuralModel
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?

    init(
        environment: EnvironmentProtocol,
        connectionManager: ConnectionManagerProtocol,
        permissionmanager: PermissionManagerProtocol,
        sharedRepository: SharedRepositoryProtocol,
        modelRepository: ModelRepositoryProtocol,
        usExaminationRepository: USExaminationRepositoryProtocol,
        applicationConfig: ApplicationConfig,
        usExaminationTypes: [USExaminationType],
        usExaminationTypesById: [String: USExaminationType],
        usExaminationTypeDefault: USExaminationType,
        usExaminationNeuralModels: [USExaminationNeuralModel],
        usExaminationNeuralModelsById: [String: USExaminationNeuralModel],
        usExaminationNeuralModelDefault: USExaminationNeuralModel,
        examinationNeuralModel: DExaminationNeuralModelProtocol?,
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?
    ) {
        self.environment = environment
        self.connectionManager = connectionManager
        self.permissionmanager = permissionmanager
        self.sharedRepository = sharedRepository
        self.modelRepository = modelRepository
        self.usExaminationRepository = usExaminationRepository
        self.applicationConfig = applicationConfig
        self.usExaminationTypes = usExaminationTypes
        self.usExaminationTypesById = usExaminationTypesById
        self.usExaminationTypeDefault = usExaminationTypeDefault
        self.usExaminationNeuralModels = usExaminationNeuralModels
        self.usExaminationNeuralModelsById = usExaminationNeuralModelsById
        self.usExaminationNeuralModelDefault = usExaminationNeuralModelDefault
        self.examinationNeuralModel = examinationNeuralModel
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }
}

extension DependencyContainer {
    var isUSExaminationNeuralModelAvailable: Bool {
        examinationNeuralModel != nil
    }

    func getUSExaminationTypeById(
        id: String
    ) -> USExaminationType? {
        usExaminationTypesById[id]
    }

    func getUSExaminationNeuralModelById(
        id: String
    ) -> USExaminationNeuralModel? {
        usExaminationNeuralModelsById[id]
    }
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
        let usExaminationRepository = USExaminationRepository(
            database: database,
            httpClient: httpClient
        )

        return DependencyContainer(
            environment: environment,
            connectionManager: ConnectionManager(),
            permissionmanager: PermissionManager(),
            sharedRepository: sharedRepository,
            modelRepository: modelRepository,
            usExaminationRepository: usExaminationRepository,
            applicationConfig: .default,
            usExaminationTypes: [],
            usExaminationTypesById: [:],
            usExaminationTypeDefault: .init(
                id: "",
                title: [:]
            ),
            usExaminationNeuralModels: [],
            usExaminationNeuralModelsById: [:],
            usExaminationNeuralModelDefault: .init(
                id: "",
                title: "",
                description: [:]
            ),
            examinationNeuralModel: nil,
            initialScreen: .onBoarding,
            initialScreenArguments: nil
        )
    }
}

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
    let examinationNeuralModel: DExaminationNeuralModelProtocol?
    let usExaminationTypes: [USExaminationType]
    let usExaminationTypesById: [String:USExaminationType]
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
        usExaminationTypes: [USExaminationType],
        usExaminationTypesById: [String:USExaminationType],
        examinationNeuralModel: DExaminationNeuralModelProtocol?,
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
        self.usExaminationTypes = usExaminationTypes
        self.usExaminationTypesById = usExaminationTypesById
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
            usExaminationTypes: [],
            usExaminationTypesById: [:],
            examinationNeuralModel: nil,
            initialScreen: .onBoarding,
            initialScreenArguments: nil
        )
    }
}

import DoglyadDatabase
import DoglyadNetwork
import DoglyadNeuralModel
import Router
import SwiftData
import SwiftUI

@Observable
final class DependencyContainer {
    let environment: EnvironmentProtocol
    let connectionManager: ConnectionManagerProtocol
    let permissionManager: PermissionManagerProtocol
    let sharedRepository: SharedRepositoryProtocol
    let ultrasoundModelRepository: UltrasoundModelRepositoryProtocol
    let ultrasoundConclusionRepository: UltrasoundConclusionRepositoryProtocol
    let templateRepository: TemplateRepositoryProtocol
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
        permissionManager: PermissionManagerProtocol,
        sharedRepository: SharedRepositoryProtocol,
        ultrasoundModelRepository: UltrasoundModelRepositoryProtocol,
        ultrasoundConclusionRepository: UltrasoundConclusionRepositoryProtocol,
        templateRepository: TemplateRepositoryProtocol,
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
        self.permissionManager = permissionManager
        self.sharedRepository = sharedRepository
        self.ultrasoundModelRepository = ultrasoundModelRepository
        self.ultrasoundConclusionRepository = ultrasoundConclusionRepository
        self.templateRepository = templateRepository
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
            type: .development,
            baseUrl: URL(filePath: "")!
        )
        let database = try! DDatabase()
        let httpClient = DHttpClient(
            baseUrl: environment.baseUrl.absoluteString,
            baseVersionPrefix: environment.baseVersionPrefix
        )
        let sharedRepository = SharedRepository(
            database: database
        )
        let ultrasoundModelRepository = UltrasoundModelRepository(
            database: database
        )
        let ultrasoundConclusionRepository = UltrasoundConclusionRepository(
            database: database,
            httpClient: httpClient
        )
        let templateRepository = TemplateRepository(
            database: database
        )

        return DependencyContainer(
            environment: environment,
            connectionManager: ConnectionManager(),
            permissionManager: PermissionManager(),
            sharedRepository: sharedRepository,
            ultrasoundModelRepository: ultrasoundModelRepository,
            ultrasoundConclusionRepository: ultrasoundConclusionRepository,
            templateRepository: templateRepository,
            applicationConfig: ApplicationConfig(
                appStoreId: "",
                actualVersion: Version(
                    major: 1,
                    minor: 0,
                    patch: 0,
                ),
                ultrasound: UltrasoundConfig(
                    defaultNeuralModelTemperature: 0.2,
                    defaultNeuralModelResponseLength: 512,
                    requestCountPerDay: 10,
                    scanPhotoMaxNumber: 0,
                    scanPhotoResizeMaxDimension: 0,
                    scanPhotoCompressionQuality: 0,
                    defaultPatientDateOfBirthGap: 0,
                    defaultPatientHeightCM: 0,
                    defaultPatientWeightKG: 0
                )
            ),
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

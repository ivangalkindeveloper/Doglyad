import DependencyInitializer
import DoglyadDatabase
import DoglyadNetwork
import FirebaseCore
import Foundation

extension InitializationProcess {
    static let preSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Environment",
            run: { (process: InitializationProcess) in
                let type = EnvironmentType(rawValue: Bundle.dictionaryString(.ENVIRONMENT)) ?? .local
                let baseUrlSchemaString = Bundle.dictionaryString(.BASE_URL_SCHEMA)
                let baseUrlString = Bundle.dictionaryString(.BASE_URL)
                let baseUrl = URL(string: "\(baseUrlSchemaString)://\(baseUrlString)")!
                process.environment = EnvironmentBase(
                    type: type,
                    baseUrl: baseUrl
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Manager",
            run: { (process: InitializationProcess) in
                process.connectionManager = ConnectionManager()
                process.connectionManager?.start()
                process.permissionmanager = PermissionManager()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Database",
            run: { (process: InitializationProcess) in
                process.database = try DDatabase()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Network",
            run: { (process: InitializationProcess) in
                process.httpClient = DHttpClient(
                    baseUrl: process.environment!.baseUrl.absoluteString
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Repository",
            run: { (process: InitializationProcess) in
                process.sharedRepository = SharedRepository(
                    database: process.database!
                )
                process.modelRepository = ModelRepository(
                    database: process.database!
                )
                process.usExaminationRepository = USExaminationRepository(
                    database: process.database!,
                    httpClient: process.httpClient!
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Firebase",
            run: { (_: InitializationProcess) in
                FirebaseApp.configure()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Internet connection",
            run: { (process: InitializationProcess) in
                let isConnected = process.connectionManager!.isConnected
                if !isConnected {
                    throw InitializationError.noInternetConnection
                }
            }
        ),
    ]
}

import DependencyInitializer
import FirebaseCore
import DoglyadNetwork
import DoglyadDatabase
import Foundation

extension InitializationProcess {
    static let preSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Environment",
            run: { (process: InitializationProcess) -> Void in
                let baseUrlSchemaString = Bundle.dictionaryString(.BASE_URL_SCHEMA)
                let baseUrlString = Bundle.dictionaryString(.BASE_URL)
                let baseUrl = URL(string: "\(baseUrlSchemaString)://\(baseUrlString)")!
                process.environment = EnvironmentBase(
                    baseUrl: baseUrl
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Manager",
            run: { (process: InitializationProcess) -> Void in
                process.connectionManager = ConnectionManager()
                process.connectionManager?.start()
                process.permissionmanager = PermissionManager()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Database",
            run: { (process: InitializationProcess) -> Void in
                process.database = try DDatabase()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Network",
            run: { (process: InitializationProcess) -> Void in
                process.httpClient = DHttpClient(
                    baseUrl: process.environment!.baseUrl.absoluteString
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Repository",
            run: { (process: InitializationProcess) -> Void in
                process.sharedRepository = SharedRepository(
                    database: process.database!
                )
                process.modelRepository = ModelRepository(
                    database: process.database!
                )
                process.diagnosticsRepository = DiagnosticsRepository(
                    database: process.database!,
                    httpClient: process.httpClient!
                )
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Firebase",
            run: { (process: InitializationProcess) -> Void in
                FirebaseApp.configure()
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Internet connection",
            run: { (process: InitializationProcess) -> Void in
                let isConnected = process.connectionManager!.isConnected
                if !isConnected {
                    throw InitializationError.noInternetConnection
                }
            }
        ),
    ]
}

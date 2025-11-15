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
            diagnosticsRepository: diagnosticsRepository,
            researchTypes: [.thyroidGland],
            initialScreen: screenType,
            initialScreenArguments: arguments
        )
    }
    
    let environment: EnvironmentProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    let initialScreenArguments: RouteArgumentsProtocol?
    
    init(
        environment: EnvironmentProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        researchTypes: [ResearchType],
        initialScreen: ScreenType,
        initialScreenArguments: RouteArgumentsProtocol?,
    ) {
        self.environment = environment
        self.diagnosticsRepository = diagnosticsRepository
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
        self.initialScreenArguments = initialScreenArguments
    }
}

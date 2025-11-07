import SwiftUI
import SwiftData

final class DependencyContainer: ObservableObject {
    let environment: EnvironmentProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let researchTypes: [ResearchType]
    let initialScreen: ScreenType
    
    init(
        environment: EnvironmentProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        researchTypes: [ResearchType],
        initialScreen: ScreenType
    ) {
        self.environment = environment
        self.diagnosticsRepository = diagnosticsRepository
        self.researchTypes = researchTypes
        self.initialScreen = initialScreen
    }
}

//
//  DependencyContainer.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import SwiftData

final class DependencyContainer: ObservableObject {
    let environment: EnvironmentProtocol
    let diagnosticsRepository: DiagnosticsRepositoryProtocol
    let initialScreen: ScreenType
    
    init(
        environment: EnvironmentProtocol,
        diagnosticsRepository: DiagnosticsRepositoryProtocol,
        initialScreen: ScreenType
    ) {
        self.environment = environment
        self.diagnosticsRepository = diagnosticsRepository
        self.initialScreen = initialScreen
    }
    
}

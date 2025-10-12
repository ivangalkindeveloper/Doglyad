//
//  InitializationProcess.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import Foundation
import SwiftData
import DependencyInitializer
import AVFoundation

final class InitializationProcess: DependencyInitializationProcess {
    typealias T = DependencyContainer
    
    var environment: EnvironmentProtocol?
    var sharedModelContainer: ModelContainer?
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    var initialScreen: ScreenType?
    
    var toContainer: DependencyContainer {
        get {
            DependencyContainer(
                environment: self.environment!,
                diagnosticsRepository: self.diagnosticsRepository!,
                initialScreen: self.initialScreen!,
            )
        }
    }
    
}

extension InitializationProcess {
    static let steps: [DependencyInitializationStep] = [
        InitializationStep<InitializationProcess>(
            title: "Environment",
            run: { process in
                let baseUrlSchemaString = Bundle.dictionaryString(.BASE_URL_SCHEMA)
                let baseUrlString = Bundle.dictionaryString(.BASE_URL)
                let baseUrl = URL(string: "\(baseUrlSchemaString)://\(baseUrlString)")!
                
                process.environment = EnvironmentBase(
                    baseURL: baseUrl
                )
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "ModelContainer",
            run: { process in
                let schema = Schema([
                    // Model
                ])
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
                process.sharedModelContainer = try ModelContainer(
                    for: schema,
                    configurations: [
                        modelConfiguration
                    ])
            }
        ),
        InitializationStep<InitializationProcess>(
            title: "DiagnosticsRepository",
            run: { process in
                process.diagnosticsRepository = DiagnosticsRepository()
            }
        ),
        AsyncInitializationStep<InitializationProcess>(
            title: "Camera Request",
            run: { process in
                await AVCaptureDevice.requestAccess(for: .video)
            }
        ),
    ]

}

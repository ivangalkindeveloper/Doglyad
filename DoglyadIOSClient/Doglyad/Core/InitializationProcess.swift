//
//  InitializationProcess.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import Foundation
import SwiftData
import DependencyInitializer

final class InitializationProcess: DependencyInitializationProcess {
    typealias T = DependencyContainer
    
    var environment: EnvironmentProtocol?
    var sharedModelContainer: ModelContainer?
    var diagnosticsRepository: DiagnosticsRepositoryProtocol?
    
    var toContainer: DependencyContainer {
        get {
            DependencyContainer(
                environment: self.environment!,
                diagnosticsRepository: self.diagnosticsRepository!,
            )
        }
    }
    
}

extension InitializationProcess {
    static let steps: [DependencyInitializationStep] = [
        InitializationStep<InitializationProcess>(
            title: "Environment",
            run: { process in
                guard let baseUrlSchemaString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL_SCHEMA") as? String else {
                    fatalError()
                }
                guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
                    fatalError()
                }
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
//                    Item.self,
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
    ]

}

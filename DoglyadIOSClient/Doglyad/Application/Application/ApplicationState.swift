//
//  DoglyadAppState.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import DependencyInitializer

@MainActor
final class ApplicationState: ObservableObject {
    @Published var root: any View = EmptyView()

    func initialize() {
        DependencyInitializer<InitializationProcess, DependencyContainer>(
            createProcess: {
                InitializationProcess()
            },
            steps: InitializationProcess.steps,
            onSuccess: { [weak self] result, _ in
//                self?.root = DependencyWrapperView(
//                    dependencyContainer: result.container,
//                    MainRootView()
//                )
                self?.root = ErrorRootView(
                    error: InitializationError.noInternetConnection
                )
            },
            onError: { [weak self] error, _, _, _ in
                self?.root = ErrorRootView(
                    error: error
                )
            }
        ).run()
    }
    
    func reload() {
        
    }
}

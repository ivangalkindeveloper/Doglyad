//
//  DoglyadAppState.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import DependencyInitializer

@MainActor
final class AppState: ObservableObject {
    @Published var root: any View = EmptyView()

    func initialize() {
        DependencyInitializer<InitializationProcess, DependencyContainer>(
            createProcess: {
                InitializationProcess()
            },
            steps: InitializationProcess.steps,
            onSuccess: { [weak self] result, _ in
                self?.root = MainRootView(
                    dependencyContainer: result.container
                )
            },
            onError: { [weak self] error, _, _, _ in
                self?.root = NavigationStack {
                    ErrorRootView(
                        error: error
                    )
                }
            }
        ).run()
    }
}

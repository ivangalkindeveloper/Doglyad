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
    @Published var isLoading = false

    func initialize() -> Void {
        isLoading = true
        DependencyInitializer<InitializationProcess, DependencyContainer>(
            createProcess: {
                InitializationProcess()
            },
            steps: InitializationProcess.steps,
            onSuccess: { [weak self] result, _ in
                guard let self = self else { return }
                isLoading = false
                //                self?.root = MainRootView(
                //                    dependencyContainer: result.container,
                //                )
                self.root = ErrorRootView(
                    error: InitializationError.noCameraRequestDenied,
                    state: self
                )
            },
            onError: { [weak self] error, _, _, _ in
                guard let self = self else { return }
                self.isLoading = false
                self.root = ErrorRootView(
                    error: error,
                    state: self
                )
            }
        ).run()
    }
}

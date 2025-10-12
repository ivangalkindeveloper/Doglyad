//
//  DoglyadApp.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import SwiftData

@main
struct Application: App {
    @StateObject private var state = ApplicationState()

    var body: some Scene {
        WindowGroup {
            ThemeWrapperView(
                AnyView(self.state.root)
                    .onAppear {
                        self.state.initialize()
                    }
            )
        }
    }
}


//
//  DoglyadApp.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import SwiftData

@main
struct DoglyadApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            AnyView(self.state.root)
                .onAppear {
                    self.state.initialize()
                }
        }
    }
}


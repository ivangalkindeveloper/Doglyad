//
//  DoglyadApp.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import SwiftData
import DoglyadUI

@main
struct Application: App {
    init() {
        FontManager().registerFonts()
    }
    
    @StateObject private var viewModel = ApplicationViewModel()

    var body: some Scene {
        WindowGroup {
            ApplicationWrapperView(
                viewModel: viewModel,
            ) {
                DThemeWrapperView {
                    AnyView(
                        self.viewModel.root
                    )
                        .onAppear {
                            self.viewModel.initialize()
                        }
                }
            }
        }
    }
}



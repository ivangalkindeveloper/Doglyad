//
//  MainRootView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

struct MainRootView: View {
    let dependencyContainer: DependencyContainer
    
    var body: some View {
        DependencyWrapperView(
            dependencyContainer: dependencyContainer,
        ) {
            RouterView<ScreenType, SheetType, FullScreenCoverType, RouterBuilder>(
                builder: RouterBuilder(),
                initialRouteScreen: RouteScreen<ScreenType>(
                    type: dependencyContainer.initialScreen
                )
            )
        }
    }
}

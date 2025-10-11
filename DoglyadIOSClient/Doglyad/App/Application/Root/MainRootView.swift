//
//  MainRootView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

struct MainRootView: View {
    @EnvironmentObject var dependencyContainer: DependencyContainer
    
    var body: some View {
        RouterView<ScreenType, SheetType, FullScreenCoverType, RouterBuilder>(
            builder: RouterBuilder(),
            initialRouteScreen: RouteScreen<ScreenType>(
                type: .onBoarding
            )
        )
    }
}

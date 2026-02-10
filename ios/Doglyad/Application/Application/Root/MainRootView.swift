import DoglyadUI
import Router
import SwiftUI

struct MainRootView: View {
    let dependencyContainer: DependencyContainer

    var body: some View {
        RouterView<ScreenType, SheetType, FullScreenCoverType, RouterBuilder>(
            builder: RouterBuilder(),
            initialRouteScreen: RouteScreen<ScreenType>(
                type: dependencyContainer.initialScreen,
                arguments: dependencyContainer.initialScreenArguments
            )
        )
        .dMessage()
        .environmentObject(dependencyContainer)
    }
}

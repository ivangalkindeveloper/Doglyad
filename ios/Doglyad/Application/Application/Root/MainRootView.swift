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
                    type: dependencyContainer.initialScreen,
                    arguments: dependencyContainer.initialScreenArguments
                )
            )
        }
    }
}

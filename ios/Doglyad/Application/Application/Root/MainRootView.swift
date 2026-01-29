import SwiftUI
import Router
import DoglyadUI

struct MainRootView: View {
    let dependencyContainer: DependencyContainer
    
    var body: some View {
        DependencyWrapperView(
            dependencyContainer: dependencyContainer,
        ) {
            DMessageView {
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
}

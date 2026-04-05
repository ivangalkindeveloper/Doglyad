import DoglyadUI
import Router
import SwiftUI

struct MainRootView: View {
    let dependencyContainer: DependencyContainer

    @State private var ultrasoundViewModel: UltrasoundViewModel

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self._ultrasoundViewModel = State(initialValue: UltrasoundViewModel(
            container: dependencyContainer
        ))
    }

    var body: some View {
        RouterView<ScreenType, SheetType, FullScreenCoverType, RouterBuilder>(
            builder: RouterBuilder(),
            initialRouteScreen: RouteScreen<ScreenType>(
                type: dependencyContainer.initialScreen,
                arguments: dependencyContainer.initialScreenArguments
            )
        )
        .dMessage()
        .environment(dependencyContainer)
        .environment(ultrasoundViewModel)
    }
}

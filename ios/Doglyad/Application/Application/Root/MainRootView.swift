import DoglyadUI
import Router
import SwiftUI

struct MainRootView: View {
    let dependencyContainer: DependencyContainer

    @StateObject private var ultrasoundViewModel: UltrasoundViewModel

    init(
        dependencyContainer: DependencyContainer
    ) {
        self.dependencyContainer = dependencyContainer
        _ultrasoundViewModel = StateObject(wrappedValue: UltrasoundViewModel(
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
        .environmentObject(dependencyContainer)
        .environmentObject(ultrasoundViewModel)
        .onAppear {
            ultrasoundViewModel.onAppear()
        }
    }
}

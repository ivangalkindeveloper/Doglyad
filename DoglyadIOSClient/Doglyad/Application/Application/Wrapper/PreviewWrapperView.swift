import SwiftUI
import DoglyadUI
import Router

struct PreviewWrapperView: View {
    let screenType: ScreenType
    let arguments: RouteArgumentsProtocol?
    
    var body: some View {
        ApplicationWrapperView(
            viewModel: ApplicationViewModel(),
        ) {
            DThemeWrapperView {
                MainRootView(
                    dependencyContainer: previewableContainer(
                        screenType: screenType,
                        arguments: arguments,
                    )
                )
            }
        }
    }
}

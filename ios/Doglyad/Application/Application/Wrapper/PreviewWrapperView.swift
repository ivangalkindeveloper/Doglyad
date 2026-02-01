import DoglyadUI
import Router
import SwiftUI

struct PreviewWrapperView: View {
    let screenType: ScreenType
    let arguments: RouteArgumentsProtocol?

    var body: some View {
        ApplicationWrapperView(
            viewModel: ApplicationViewModel()
        ) {
            DThemeWrapperView {
                MainRootView(
                    dependencyContainer: previewableContainer(
                        screenType: screenType,
                        arguments: arguments
                    )
                )
            }
        }
    }
}

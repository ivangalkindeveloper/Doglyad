import DoglyadUI
import Router
import SwiftUI

final class OnBoardingScreenArguments: RouteArgumentsProtocol {}

struct OnBoardingScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: OnBoardingScreenArguments?

    var body: some View {
        OnBoardingScreenView(
            viewModel: OnBoardingViewModel(
                sharedRepository: container.sharedRepository,
                diagnosticRepository: container.diagnosticsRepository,
                router: router
            )
        )
    }
}

#Preview {
    PreviewWrapperView(
        screenType: .onBoarding,
        arguments: nil
    )
}

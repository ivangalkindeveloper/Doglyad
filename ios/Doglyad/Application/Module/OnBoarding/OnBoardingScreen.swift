import DoglyadUI
import Router
import SwiftUI

struct OnBoardingScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var router: DRouter
    let arguments: OnBoardingScreenArguments?

    var body: some View {
        OnBoardingScreenView(
            viewModel: OnBoardingViewModel(
                environment: container.environment,
                sharedRepository: container.sharedRepository,
                diagnosticRepository: container.diagnosticsRepository,
                router: router
            )
        )
    }
}

#Preview {
    OnBoardingScreen(
        arguments: nil
    )
    .previewable()
}

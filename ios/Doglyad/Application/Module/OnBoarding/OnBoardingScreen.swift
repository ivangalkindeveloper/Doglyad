import SwiftUI
import Router
import DoglyadUI

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
    
private struct OnBoardingScreenView: View {
    @EnvironmentObject var theme: DTheme
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }
    
    @StateObject var viewModel: OnBoardingViewModel
    
    var body: some View {
        DScreen { toolbarInset in
            VStack(
                alignment: .leading,
                spacing: .zero,
            ) {
                DText(.onBoardingTitle)
                .dStyle(
                    font: typography.displayLargeBold,
                )
                .padding(size.s16)
                
                TabView(
                    selection: $viewModel.page
                ) {
                    OnBoardingScreenPage(
                        description: .onBoardingIntroDescription,
                        tag: .intro
                    )
                    OnBoardingScreenPage(
                        description: .onBoardingResearchTypeDescription,
                        tag: .researchType
                    )
                    OnBoardingScreenPage(
                        description: .onBoardingScanDescription,
                        tag: .scan
                    )
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: viewModel.page)
                .allowsHitTesting(false)
                .padding(.bottom, size.s16)
                
                DButton(
                    title: viewModel.buttonTitle(viewModel.page),
                    action: viewModel.onPressedNext
                )
                .dStyle(.primaryButton)
                .padding(size.s16)
            }
        }
    }
}

private struct OnBoardingScreenPage: View {
    @EnvironmentObject var theme: DTheme
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }
    
    let description: LocalizedStringResource
    let tag: OnBoardingViewModel.Page
    
    var body: some View {
        DText(
            description,
        )
        .dStyle(
            font: typography.textMedium,
            alignment: .center
        )
        .padding(size.s16)
        .tag(tag)
    }
}

#Preview {
    PreviewWrapperView(
        screenType: .onBoarding,
        arguments: nil
    )
}

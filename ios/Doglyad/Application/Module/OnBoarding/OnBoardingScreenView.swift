import DoglyadUI
import SwiftUI

struct OnBoardingScreenView: View {
    @EnvironmentObject var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @StateObject var viewModel: OnBoardingViewModel

    var body: some View {
        DScreen { _ in
            VStack(
                alignment: .leading,
                spacing: .zero
            ) {
                DText(.onBoardingTitle)
                    .dStyle(
                        font: typography.displayLargeBold
                    )
                    .padding(size.s16)

                TabView(
                    selection: $viewModel.page
                ) {
                    OnBoardingPageView(
                        description: .onBoardingIntroDescription,
                        tag: .intro
                    )
                    OnBoardingPageView(
                        description: .onBoardingResearchTypeDescription,
                        tag: .researchType
                    )
                    OnBoardingPageView(
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

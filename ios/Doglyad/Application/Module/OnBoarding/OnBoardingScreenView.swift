import DoglyadUI
import SwiftUI

struct OnBoardingScreenView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    private var color: DColor { theme.color }

    @StateObject var viewModel: OnBoardingViewModel

    var body: some View {
        DScreen(
            content: { _, _ in
                VStack(
                    alignment: .leading,
                    spacing: .zero
                ) {
                    stepper
                        .padding(.bottom, size.s16)

                    DText(.onBoardingTitle)
                        .dStyle(
                            font: typography.displayLargeBold
                        )
                        .padding(.bottom, size.s16)

                    currentPage
                        .id(viewModel.page)
                        .transition(.opacity)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
                .padding(.top, size.s16)
                .padding(.horizontal, size.s16)
                .padding(.bottom, size.s64)
                .animation(.easeInOut, value: viewModel.page)
            },
            bottom: {
                DButton(
                    title: viewModel.buttonTitle(viewModel.page),
                    action: viewModel.onPressedNext,
                    isDisabled: viewModel.isLegalDisabled
                )
                .dStyle(.primaryButton)
                .padding(size.s16)
            }
        )
    }

    private var stepper: some View {
        HStack(
            spacing: size.s4
        ) {
            ForEach(
                Array(OnBoardingViewModel.Page.allCases.enumerated()),
                id: \.offset
            ) { index, _ in
                Capsule()
                    .fill(
                        index <= viewModel.page.index
                            ? color.primaryDefault
                            : color.grayscaleLine
                    )
                    .frame(height: size.s2)
            }
        }
    }

    @ViewBuilder
    private var currentPage: some View {
        switch viewModel.page {
        case .first:
            OnBoardingPageView(
                tag: .first,
                image: .onBoarding1,
                description: .onBoardingDescriptionFirst
            )
        case .second:
            OnBoardingPageView(
                tag: .second,
                image: .onBoarding2,
                description: .onBoardingDescriptionSecond
            )
        case .third:
            OnBoardingPageView(
                tag: .third,
                image: .onBoarding3,
                description: .onBoardingDescriptionThird
            ) {
                HStack(
                    alignment: .center
                ) {
                    DCheckbox(
                        isChecked: $viewModel.isLegalAccepted
                    )
                    .padding(.trailing, size.s8)

                    Text(viewModel.legalAttributedText(theme: theme, locale: locale))
                        .multilineTextAlignment(.leading)
                        .tint(color.grayscaleHeader)
                        .environment(\.openURL, OpenURLAction { url in
                            viewModel.onLegalAttributedEnvironment(url: url)
                        })
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, size.s16)
                .padding(.horizontal, size.s16)
            }
        case .fourth:
            OnBoardingPageView(
                tag: .fourth,
                image: .onBoarding4,
                description: .onBoardingDescriptionFourth
            )
        case .fifth:
            OnBoardingPageView(
                tag: .fifth,
                image: .onBoarding5,
                description: .onBoardingDescriptionFifth
            )
        }
    }
}

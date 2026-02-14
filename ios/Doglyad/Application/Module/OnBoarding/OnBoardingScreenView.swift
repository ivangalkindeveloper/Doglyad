import DoglyadUI
import SwiftUI

struct OnBoardingScreenView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    private var color: DColor { theme.color }
    
    @StateObject var viewModel: OnBoardingViewModel

    var body: some View {
        DScreen { toolbarInset in
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
                        tag: .first,
                        image: .alertInfo,
                        description: .onBoardingDescriptionFirst
                    )
                    OnBoardingPageView(
                        tag: .second,
                        image: .alertInfo,
                        description: .onBoardingDescriptionSecond
                    )
                    OnBoardingPageView(
                        tag: .third,
                        image: .alertInfo,
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
                        .padding(.horizontal, size.s8)
                    }
                    OnBoardingPageView(
                        tag: .fourth,
                        image: .alertInfo,
                        description: .onBoardingDescriptionFourth
                    )
                    OnBoardingPageView(
                        tag: .fifth,
                        image: .alertInfo,
                        description: .onBoardingDescriptionFifth
                    )
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: viewModel.page)
                .highPriorityGesture(DragGesture().onChanged { _ in })
                .padding(.bottom, size.s16)

                DButton(
                    title: viewModel.buttonTitle(viewModel.page),
                    action: viewModel.onPressedNext,
                    isDisabled: viewModel.isLegalDisabled
                )
                .dStyle(.primaryButton)
                .padding(.horizontal, size.s16)
                .padding(.bottom, size.s16)
            }
        }
    }
}

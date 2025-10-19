//
//  OnBoardingScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

final class OnBoardingScreenArguments: RouteArgumentsProtocol {}
    
struct OnBoardingScreen: View {
    @EnvironmentObject private var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: OnBoardingScreenArguments?
    @StateObject private var viewModel = OnBoardingViewModel()
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0,
        ) {
            DText(
                L10n.onBoardingTitle.string,
            )
            .dStyle(
                font: typography.displayLargeBold,
            )
            .padding(size.s16)
            TabView(
                selection: $viewModel.page
            ) {
                Page(
                    description: .onBoardingIntroDescription,
                    tag: .intro
                )
                Page(
                    description: .onBoardingResearchTypeDescription,
                    tag: .researchType
                )
                Page(
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
                title: title(viewModel.page).string,
                action: {
                    viewModel.onPressedNext(
                        router: router
                    )
                }
            )
            .padding(size.s16)
        }

    }
}

private extension OnBoardingScreen {
    func title(
        _ page: OnBoardingViewModel.Page
    ) -> L10n {
        switch page {
        case .intro:
            L10n.buttonNext
        case .researchType:
            L10n.buttonSelectType
        case .scan:
            L10n.buttonStart
        }
    }
}

private struct Page: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let description: L10n
    let tag: OnBoardingViewModel.Page
    
    var body: some View {
        DText(
            description.string,
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
    ApplicationWrapperView {
        DThemeWrapperView {
            OnBoardingScreen(
                arguments: nil
            )
        }
    }
}

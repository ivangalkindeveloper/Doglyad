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
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: OnBoardingScreenArguments?
    @StateObject private var viewModel = OnBoardingViewModel()
    
    var body: some View {
        DScreen {
            VStack(
                alignment: .leading,
                spacing: .zero,
            ) {
                DText(
                    .onBoardingTitle,
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
                    title: title(viewModel.page),
                    action: viewModel.onPressedNext
                )
                .dStyle(.primaryButton)
                .padding(size.s16)
            }
        }
        .onAppear {
            viewModel.diagnosticRepository = container.diagnosticsRepository
            viewModel.router = router
        }
    }
}

private extension OnBoardingScreen {
    func title(
        _ page: OnBoardingViewModel.Page
    ) -> LocalizedStringResource {
        switch page {
        case .intro:
            .buttonNext
        case .researchType:
            .buttonSelectType
        case .scan:
            .buttonStart
        }
    }
}

private struct Page: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
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

//#Preview {
//    ApplicationWrapperView {
//        DependencyWrapperView(
//            dependencyContainer:
//        ) {
//            DThemeWrapperView {
//                OnBoardingScreen(
//                    arguments: nil
//                )
//            }
//        }
//    }
//}

//
//  RootRouter.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class RouterBuilder: RouterBuilderProtocol {
    typealias Screen = ScreenType
    typealias Sheet = SheetType
    typealias FullScreenCover = FullScreenCoverType
    typealias Content = AnyView
    
    func build(
        route: RouteScreen<ScreenType>
    ) -> AnyView {
        switch route.type {
        case .onBoarding:
            AnyView(OnBoardingScreen(
                arguments: route.arguments as? OnBoardingScreenArguments
            ))
            
        case .scan:
            AnyView(ScanScreen(
                arguments: route.arguments as? ScanScreenArguments
            ))

        case .history:
            AnyView(HistoryScreen(
                arguments: route.arguments as? HistoryScreenArguments
            ))

        case .conclusion:
            AnyView(ConclusionScreen(
                arguments: route.arguments as? ConclusionScreenArguments
            ))
        }
    }
    
    @ViewBuilder
    func build(
        route: RouteSheet<SheetType>
    ) -> AnyView {
        switch route.type {
        case .researchType:
            AnyView(ResearchTypeScreen(
                arguments: route.arguments as? ResearchTypeScreenArguments
            ))
        }
    }
    
    @ViewBuilder
    func build(
        route: RouteFullScreenCover<FullScreenCoverType>
    ) -> AnyView {
        switch route.type {
        case .some:
            AnyView(EmptyView())
        }
    }
}

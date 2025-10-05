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
        case .anamnesis:
            AnyView(AnamnesisScreenView(
                arguments: route.arguments as? AnamnesisScreenArguments
            ))
            
        case .diagnosis:
            AnyView(DiagnosisScreenView(
                arguments: route.arguments as? DiagnosisScreenArguments
            ))
            
        case .history:
            AnyView(HistoryScreenView(
                arguments: route.arguments as? HistoryScreenArguments
            ))
            
        case .researchType:
            AnyView(ResearchTypeScreenView(
                arguments: route.arguments as? ResearchTypeScreenArguments
            ))
        }
    }
    
    @ViewBuilder
    func build(
        route: RouteSheet<SheetType>
    ) -> AnyView {
        switch route.type {
        case .some:
            AnyView(EmptyView())
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

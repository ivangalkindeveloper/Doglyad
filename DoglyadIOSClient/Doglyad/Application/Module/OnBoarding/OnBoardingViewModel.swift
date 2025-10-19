//
//  OnBoardingViewModel.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import Foundation
import SwiftUI
import Router

final class OnBoardingViewModel: ObservableObject {
    enum Page {
        case intro
        case researchType
        case scan
    }
    
    @Published var page: Page = .intro
    
    func onPressedNext(
        router: DRouter,
    ) -> Void {
        switch page {
        case .intro:
            page = .researchType
            
        case .researchType:
            page = .scan
            
        case .scan:
            router.push(
                route: RouteScreen(
                    type: .scan
                )
            )
        }
    }
}

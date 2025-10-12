//
//  OnBoardingScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI
import Router

final class OnBoardingScreenArguments: RouteArgumentsProtocol {}
    
struct OnBoardingScreenView: View {
    let arguments: OnBoardingScreenArguments?
    @StateObject var viewModel = OnBoardingViewModel()
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    HistoryScreenView(
        arguments: nil
    )
}

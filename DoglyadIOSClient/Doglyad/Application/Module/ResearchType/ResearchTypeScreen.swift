//
//  ResearchTypeScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

final class ResearchTypeScreenArguments: RouteArgumentsProtocol {}
    
struct ResearchTypeScreen: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: ResearchTypeScreenArguments?
    @StateObject private var viewModel = ResearchTypeViewModel()
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    ResearchTypeScreen(
        arguments: nil
    )
}

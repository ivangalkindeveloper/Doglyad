//
//  DiagnosisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

final class ConclusionScreenArguments: RouteArgumentsProtocol {}

struct ConclusionScreen: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: ConclusionScreenArguments?
    @StateObject var viewModel = ConclusionViewModel()
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    ConclusionScreen(
        arguments: nil
    )
}

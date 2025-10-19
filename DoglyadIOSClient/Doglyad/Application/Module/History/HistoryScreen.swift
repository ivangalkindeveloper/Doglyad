//
//  HistoryScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

final class HistoryScreenArguments: RouteArgumentsProtocol {}
    
struct HistoryScreen: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: HistoryScreenArguments?
    @StateObject var viewModel = HistoryViewModel()
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    HistoryScreen(
        arguments: nil
    )
}

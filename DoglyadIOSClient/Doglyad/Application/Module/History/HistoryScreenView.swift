//
//  HistoryScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class HistoryScreenArguments: RouteArgumentsProtocol {}
    
struct HistoryScreenView: View {
    let arguments: HistoryScreenArguments?
    @StateObject var viewModel = HistoryViewModel()
    
    var body: some View {
        Text("HistoryScreenView")
    }
}

#Preview {
    HistoryScreenView(
        arguments: nil
    )
}

//
//  DiagnosisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class ConclusionScreenArguments: RouteArgumentsProtocol {}

struct ConclusionScreenView: View {
    let arguments: ConclusionScreenArguments?
    @StateObject var viewModel = ConclusionViewModel()
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    ConclusionScreenView(
        arguments: nil
    )
}

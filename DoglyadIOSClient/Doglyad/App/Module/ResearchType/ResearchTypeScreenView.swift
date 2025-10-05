//
//  ResearchTypeScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class ResearchTypeScreenArguments: RouteArgumentsProtocol {}
    
struct ResearchTypeScreenView: View {
    let arguments: ResearchTypeScreenArguments?
    @StateObject var viewModel = ResearchTypeViewModel()
    
    var body: some View {
        Text("ResearchTypeScreenView")
    }
}

#Preview {
    ResearchTypeScreenView(
        arguments: nil
    )
}

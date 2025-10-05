//
//  AnamnesisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class AnamnesisScreenArguments: RouteArgumentsProtocol {}

struct AnamnesisScreenView: View {
    let arguments: AnamnesisScreenArguments?
    @StateObject var viewModel = AnamnesisViewModel()
    
    var body: some View {
        Text("AnamnesisScreenView")
    }
}

#Preview {
    AnamnesisScreenView(
        arguments: nil
    )
}

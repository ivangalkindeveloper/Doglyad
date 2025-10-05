//
//  DiagnosisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router

final class DiagnosisScreenArguments: RouteArgumentsProtocol {}

struct DiagnosisScreenView: View {
    let arguments: DiagnosisScreenArguments?
    @StateObject var viewModel = DiagnosisViewModel()
    
    var body: some View {
        Text("DiagnosisScreenView")
    }
}

#Preview {
    DiagnosisScreenView(
        arguments: nil
    )
}

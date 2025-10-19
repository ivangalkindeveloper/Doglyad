//
//  AnamnesisScreenView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import Router
import DoglyadUI

final class ScanScreenArguments: RouteArgumentsProtocol {}

struct ScanScreen: View {
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: ScanScreenArguments?
    @StateObject private var viewModel = ScanViewModel()
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        ZStack {
            CameraView(
                viewModel: cameraViewModel
            )
                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Button(
                        action: cameraViewModel.takePhoto
                    ) {
                        Circle()
                            .stroke(lineWidth: 5)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().fill(Color.white.opacity(0.3)))
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}

#Preview {
    ScanScreen(
        arguments: nil
    )
}

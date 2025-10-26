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
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: ScanScreenArguments?
    @StateObject private var viewModel = ScanViewModel()
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        DScreen {
            ZStack {
                CameraView(
                    viewModel: cameraViewModel
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        DButton(
                            image: .hambergerMenu,
                            action: {},
                        )
                        .dStyle(.circle)
                        .padding(.leading, size.s16)
                        
                        Spacer()
                        
                        if let researchType = viewModel.researchType {
                            DButton(
                                title: L10n.forUSResearchType(researchType.type).string,
                                action: viewModel.onPressedHistory,
                            )
                            .dStyle(.primaryChip)
                            .padding([.trailing, .leading], size.s16)
                        }

                        Spacer()
                        
                        EmptyView()
                            .frame(
                                width: size.s56,
                                height: size.s56,
                            )
                            .padding(.trailing, size.s16)
                    }
                    Spacer()
                    DButton(
                        image: .camera,
                        action: {
                            cameraViewModel.takePhoto(
                                completion: { image in
                                    self.viewModel.capturePhoto(image: image)
                                }
                            )
                        },
                        isLoading: cameraViewModel.isCapturing
                    )
                    .dStyle(.primaryCircle)
                    .padding(.bottom, viewModel.isShowBottomSheet ? size.s96 : size.s16)
                }
                .padding(size.s16)
            }
        }
        .sheet(
            isPresented: $viewModel.isShowBottomSheet
        ) {
            ScanBottomSheet()
        }
        .onAppear {
            viewModel.diagnosticRepository = container.diagnosticsRepository
            viewModel.router = router
            cameraViewModel.startSession()
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

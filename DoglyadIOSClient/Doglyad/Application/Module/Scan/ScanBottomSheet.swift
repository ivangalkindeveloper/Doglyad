//
//  ScanBottomSheet.swift
//  Doglyad
//
//  Created by Иван Галкин on 23.10.2025.
//

import SwiftUI
import DoglyadUI

struct ScanBottomSheet: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        VStack(spacing: .zero) {
            ScrollView(.horizontal) {
                ForEach(viewModel.photos) { photo in
                    DPhotoCard(
                        image: photo.image,
                        actionDelete: {
                            viewModel.onPressedDeletePhoto(photo: photo)
                        }
                    )
                    .padding([.horizontal], size.s8)
                }
                .padding([.horizontal], size.s8)
            }
            .padding(.top, size.s24)
            .padding(.bottom, size.s16)
            
        }
        .background(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(size.s20)
        .presentationDetents([.large, .height(100)])
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
    }
}

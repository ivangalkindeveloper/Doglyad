//
//  ScanBottomSheet.swift
//  Doglyad
//
//  Created by Иван Галкин on 23.10.2025.
//

import SwiftUI
import DoglyadUI
import BottomSheet

struct ScanSheet: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ScrollView(.horizontal) {
                    HStack(spacing: .zero) {
                        ForEach(viewModel.photos) { photo in
                            DPhotoCard(
                                image: photo.image,
                                actionDelete: {
                                    viewModel.onPressedDeletePhoto(photo: photo)
                                }
                            )
                        }
                        .padding([.horizontal], size.s4)
                    }
                    .padding([.horizontal], size.s12)
                }
                .padding(.bottom, size.s16)
                VStack(spacing: .zero) {
                    
                    DInput<EmptyView>(
                        placeholder: L10n.fieldPatientName.string,
                        controller: viewModel.nameController
                    )
                    .padding(.bottom, size.s16)
                    
                    // gender
                    
                    // age
                    
                    // medicalHistory
                    
                    // сurrentComplaint
                    
                    DButton(
                        title: L10n.buttonScan.string,
                        action: viewModel.onPressedScan
                    )
                    .dStyle(.primaryButton)
                }
                .padding([.horizontal], size.s16)
            }
        }
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

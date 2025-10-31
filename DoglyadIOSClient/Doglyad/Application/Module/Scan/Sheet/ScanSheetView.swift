//
//  ScanSheetView.swift
//  Doglyad
//
//  Created by Иван Галкин on 23.10.2025.
//

import SwiftUI
import DoglyadUI
import BottomSheet

struct ScanSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            
            DInput<EmptyView>(
                placeholder: .fieldPatientName,
                controller: viewModel.nameController
            )
            .padding(.bottom, size.s16)
            
            // gender
            
            // age
            
            // medicalHistory
            
            // сurrentComplaint
            
            DButton(
                title: .buttonScan,
                action: viewModel.onPressedScan
            )
            .dStyle(.primaryButton)
        }
        .padding([.horizontal], size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

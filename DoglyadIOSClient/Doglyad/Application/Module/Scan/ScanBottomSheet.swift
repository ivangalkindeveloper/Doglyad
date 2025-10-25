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
    
    var body: some View {
        VStack {
            Text("Hello!")
        }
        .background(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(size.s20)
        .presentationDetents([.large, .height(100)])
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
    }
}

//
//  DBottomSheet.swift
//  Doglyad
//
//  Created by Иван Галкин on 19.10.2025.
//

import SwiftUI

public struct DBottomSheet<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let title: String
    let content: () -> Content
    
    public init(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: .zero) {
            DText(title)
                .dStyle(
                    font: typography.linkMedium
                )
                .padding(size.s16)
            Spacer()
            content()
            Spacer()
        }
        .presentationBackground(color.grayscaleBackgroundWeak)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(size.s16)
        .presentationCornerRadius(size.s20)
        .presentationDetents([.fraction(0.3)])
    }
}

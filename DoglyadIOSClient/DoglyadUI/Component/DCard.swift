//
//  DCard.swift
//  Doglyad
//
//  Created by Иван Галкин on 25.10.2025.
//

import SwiftUI

public struct DCard<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var typography: DTypography { theme.typography }
    
    let action: () -> Void
    let content: () -> Content
    
    public init(
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: action
        ) {
            content()
        }
        .buttonStyle(DTapStyle(
            backgroundColor: color.grayscaleBackground,
            maxWidth: .infinity
        ))
    }
}

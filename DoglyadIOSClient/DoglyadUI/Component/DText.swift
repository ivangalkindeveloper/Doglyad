//
//  DText.swift
//  Doglyad
//
//  Created by Иван Галкин on 09.10.2025.
//

import SwiftUI

public struct DText: View {
    let data: LocalizedStringResource
    
    public init(
        _ data: LocalizedStringResource,
    ) {
        self.data = data
    }
    
    public var body: some View {
        Text(data)
    }
}

public extension DText {
    func dStyle(
        font: Font? = nil,
        color: Color? = nil,
        alignment: TextAlignment? = nil,
    ) -> some View {
        self.modifier(DTextModifier(
            font: font,
            color: color,
            alignment: alignment,
        ))
    }
}

private struct DTextModifier: ViewModifier {
    @EnvironmentObject private var theme: DTheme
    private var typography: DTypography { theme.typography }
    
    let font: Font?
    let color: Color?
    let alignment: TextAlignment?
    
    init(
        font: Font?,
        color: Color?,
        alignment: TextAlignment?,
    ) {
        self.font = font
        self.color = color
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .font(font ?? typography.textMedium)
            .foregroundStyle(color ?? theme.color.grayscaleHeader)
            .multilineTextAlignment(alignment ?? .leading)
    }
}

#Preview {
    DThemeWrapperView {
        DText(
            "Hello, World!",
        )
    }
}

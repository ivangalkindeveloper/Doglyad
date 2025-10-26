//
//  DButtonStyle.swift
//  Doglyad
//
//  Created by Иван Галкин on 20.10.2025.
//

import SwiftUI

enum DButtunStyleType {
    case primaryButton
    case primaryCircle
    case primaryChip
    case circle
    case card
}

public struct DButtonStyle: ButtonStyle {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    
    let backgroundColor: Color?
    let backgroundGradient: LinearGradient?
    let cornerRadius: CGFloat?
    let maxWidth: CGFloat?
    
    public init(
        backgroundColor: Color? = nil,
        backgroundGradient: LinearGradient? = nil,
        cornerRadius: CGFloat? = nil,
        maxWidth: CGFloat? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundGradient = backgroundGradient
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(size.s14)
            .frame(maxWidth: maxWidth)
            .background(
                Group {
                    if let backgroundColor = backgroundColor {
                        RoundedRectangle(cornerRadius: cornerRadius ?? size.s16)
                            .fill(backgroundColor)
                    }
                    if let backgroundGradient = backgroundGradient {
                        RoundedRectangle(cornerRadius: cornerRadius ?? size.s16)
                            .fill(backgroundGradient)
                    }
                }
            )
            .foregroundColor(color.grayscaleBackground)
            .opacity(configuration.isPressed ? 0.6: 1)
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

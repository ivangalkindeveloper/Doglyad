//
//  DButtonStyle.swift
//  Doglyad
//
//  Created by Иван Галкин on 20.10.2025.
//

import SwiftUI

public enum DButtonStyleType {
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

    let type: DButtonStyleType

    public init(
        _ type: DButtonStyleType
    ) {
        self.type = type
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(size.s14)
            .frame(
                width: width,
                height: height
            )
            .frame(
                maxWidth: maxWidth
            )
            .progressViewStyle(
                CircularProgressViewStyle(tint: foregroundColor)
            )
            .foregroundColor(foregroundColor)
            .foregroundStyle(foregroundColor)
            .background(background)
            .opacity(
                configuration.isPressed ? 0.6 : 1
            )
            .animation(
                .easeOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

private extension DButtonStyle {
    static let defaultGradient: LinearGradient = .init(colors: [], startPoint: .top, endPoint: .top)
    static let defaultColor: Color = .clear

    var backgroundGradient: LinearGradient? {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return color.gradientPrimaryWeak
        case .circle, .card:
            return nil
        }
    }

    var backgroundColor: Color? {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return nil
        case .circle, .card:
            return color.grayscaleBackground
        }
    }
    
    @ViewBuilder
    var background: some View {
        let cornerRadius = self.cornerRadius ?? size.s16
        switch type {
        case .primaryButton:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundGradient ?? DButtonStyle.defaultGradient)
            
        case .primaryCircle:
            Circle()
                .fill(backgroundGradient ?? DButtonStyle.defaultGradient)

        case .primaryChip:
            Capsule()
                .fill(backgroundGradient ?? DButtonStyle.defaultGradient)

        case .circle:
            Circle()
                .fill(backgroundColor ?? DButtonStyle.defaultColor)
            
        case .card:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor ?? DButtonStyle.defaultColor)
        }
    }

    var foregroundColor: Color {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return color.grayscaleBackground
        case .circle, .card:
            return color.grayscaleHeader
        }
    }

    var cornerRadius: CGFloat? {
        switch type {
        case .primaryButton, .card:
            return size.s16
        case .primaryCircle, .primaryChip, .circle:
            return nil
        }
    }

    var width: CGFloat? {
        switch type {
        case .primaryButton, .primaryChip, .card:
            return nil
        case .primaryCircle, .circle:
            return size.s56
        }
    }

    var height: CGFloat? {
        switch type {
        case .primaryButton, .primaryChip, .card:
            return nil
        case .primaryCircle, .circle:
            return size.s56
        }
    }

    var maxWidth: CGFloat? {
        switch type {
        case .primaryButton, .card:
            return .infinity
        case .primaryCircle, .primaryChip, .circle:
            return nil
        }
    }
}

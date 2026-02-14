import SwiftUI

public enum DButtonStyleType {
    case primaryButton
    case primaryCircle
    case primaryChip
    case circle
    case card
    case chip
}

public struct DButtonStyle: ButtonStyle {
    @EnvironmentObject private var theme: DTheme
    @Environment(\.isEnabled) private var isEnabled
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
                CircularProgressViewStyle(tint: currentForegroundColor)
            )
            .foregroundColor(currentForegroundColor)
            .foregroundStyle(currentForegroundColor)
            .background(currentBackground)
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

    var backgroundGradient: LinearGradient {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return color.gradientPrimaryWeak
        case .circle, .card, .chip:
            return Self.defaultGradient
        }
    }

    var backgroundColor: Color {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return Self.defaultColor
        case .circle, .card, .chip:
            return color.grayscaleBackground
        }
    }

    var foregroundColor: Color {
        switch type {
        case .primaryButton, .primaryCircle, .primaryChip:
            return color.grayscaleBackground
        case .circle, .card, .chip:
            return color.grayscaleHeader
        }
    }

    var currentForegroundColor: Color {
        isEnabled ? foregroundColor : color.grayscalePlacehold
    }

    @ViewBuilder
    var currentBackground: some View {
        if isEnabled {
            enabledBackground
        } else {
            disabledBackground
        }
    }

    @ViewBuilder
    var enabledBackground: some View {
        let cornerRadius = self.cornerRadius ?? size.s16
        switch type {
        case .primaryButton:
            RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundGradient)
        case .primaryCircle:
            Circle()
                .fill(backgroundGradient)
        case .primaryChip:
            Capsule()
                .fill(backgroundGradient)
        case .circle:
            Circle()
                .fill(backgroundColor)
        case .card:
            RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
        case .chip:
            Capsule()
                .fill(backgroundColor)
        }
    }

    @ViewBuilder
    var disabledBackground: some View {
        let cornerRadius = self.cornerRadius ?? size.s16
        switch type {
        case .primaryButton:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.grayscaleInput)
        case .primaryCircle:
            Circle()
                .fill(color.grayscaleInput)
        case .primaryChip:
            Capsule()
                .fill(color.grayscaleInput)
        case .circle:
            Circle()
                .fill(color.grayscaleInput)
        case .card:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.grayscaleInput)
        case .chip:
            Capsule()
                .fill(color.grayscaleInput)
        }
    }

    var cornerRadius: CGFloat? {
        switch type {
        case .primaryButton:
            return size.adaptiveCornerRadius
        case .card:
            return size.adaptiveCardCornerRadius
        case .primaryCircle, .primaryChip, .circle, .chip:
            return nil
        }
    }

    var width: CGFloat? {
        switch type {
        case .primaryButton, .primaryChip, .card, .chip:
            return nil
        case .primaryCircle, .circle:
            return size.s56
        }
    }

    var height: CGFloat? {
        switch type {
        case .primaryButton, .primaryChip, .card, .chip:
            return nil
        case .primaryCircle, .circle:
            return size.s56
        }
    }

    var maxWidth: CGFloat? {
        switch type {
        case .primaryButton, .card:
            return .infinity
        case .primaryCircle, .primaryChip, .circle, .chip:
            return nil
        }
    }
}

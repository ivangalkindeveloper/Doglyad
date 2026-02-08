import SwiftUI

struct DMessageCard: View {
    let theme: DTheme
    let message: DMessage

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            Text(
                message.title
            )
            .font(typography.linkSmall)
            .foregroundStyle(theme.color.grayscaleBackground)
            .multilineTextAlignment(.leading)

            if let description = message.description {
                Text(
                    description
                )
                .font(typography.textXSmall)
                .foregroundStyle(theme.color.grayscaleBackground)
                .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, size.s16)
        .padding(.vertical, size.s12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(
                cornerRadius: theme.size.adaptiveCardCornerRadius
            )
            .fill(backgroundColor)
        )
    }
}

private extension DMessageCard {
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    var backgroundColor: LinearGradient {
        switch message.type {
        case .success:
            color.gradientPrimaryWeak
        case .error:
            color.gradientAccent
        }
    }
}

#Preview {
    DThemeWrapperView {
        DMessageCard(
            theme: DTheme.light,
            message: DMessage(
                type: .error,
                title: "Title",
                description: "Description"
            )
        )
        .padding()
    }
}

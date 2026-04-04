import SwiftUI

public struct DButtonCard<Content: View>: View {
    @Environment(DTheme.self) private var theme
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
        .buttonStyle(DButtonStyle(.card))
    }
}

#Preview {
    VStack(spacing: 16) {
        DButtonCard(
            action: { print("Tap") }
        ) {
            HStack {
                DIcon(.alertInfo)
                DText("Button card")
                    .dStyle()
                Spacer()
            }
        }

        DButtonCard(
            action: { print("Tap") }
        ) {
            DText("Simple card")
                .dStyle()
        }
    }
    .padding()
    .dThemeWrapper()
}

import SwiftUI
internal import SwiftMessages

private struct DMessageModifier: ViewModifier {
    @Environment(DTheme.self) private var theme

    @State var messager = DMessager()

    func body(content: Content) -> some View {
        @Bindable var messager = messager

        content
            .swiftMessage(
                message: $messager.message
            ) { message in
                DMessageCard(
                    theme: theme,
                    message: message
                )
                .padding(.top, theme.size.s4)
                .padding(.horizontal, theme.size.s16)
            }
            .environment(messager)
    }
}

public extension View {
    func dMessage() -> some View {
        modifier(DMessageModifier())
    }
}

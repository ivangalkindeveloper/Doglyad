import SwiftUI
internal import SwiftMessages

public struct DMessageView<Content: View>: View {
    @EnvironmentObject private var theme: DTheme

    @StateObject var messager = DMessager()

    @ViewBuilder let content: () -> Content

    public init(
        content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        content()
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
            .environmentObject(messager)
    }
}

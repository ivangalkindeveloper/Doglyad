import SwiftUI

private struct DThemeWrapperModifier: ViewModifier {
    @State private var theme = DTheme.light

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.light)
            .environment(theme)
    }
}

public extension View {
    func dThemeWrapper() -> some View {
        modifier(DThemeWrapperModifier())
    }
}

import SwiftUI

private struct DThemeWrapperModifier: ViewModifier {
    @StateObject private var theme = DTheme.light

    func body(content: Content) -> some View {
        content
            .environmentObject(theme)
    }
}

public extension View {
    func dThemeWrapper() -> some View {
        modifier(DThemeWrapperModifier())
    }
}

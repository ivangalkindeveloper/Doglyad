import DoglyadUI
import Router
import SwiftUI

private struct PreviewableModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .environmentObject(DRouter(initialRoute: RouteScreen(
                type: .onBoarding,
                arguments: nil
            )))
            .dMessage()
            .dThemeWrapper()
            .environmentObject(DependencyContainer.previewable)
            .environmentObject(ApplicationViewModel())
    }
}

extension View {
    func previewable() -> some View {
        modifier(PreviewableModifier())
    }
}

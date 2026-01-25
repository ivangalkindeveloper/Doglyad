import SwiftUI

struct DependencyWrapperView<Content: View>: View {
    let dependencyContainer: DependencyContainer
    @ViewBuilder  let content: () -> Content

    init(
        dependencyContainer: DependencyContainer,
        content: @escaping () -> Content
    ) {
        self.dependencyContainer = dependencyContainer
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(dependencyContainer)
    }
}

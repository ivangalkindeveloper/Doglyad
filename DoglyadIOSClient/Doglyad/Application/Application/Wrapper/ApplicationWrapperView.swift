import SwiftUI

struct ApplicationWrapperView<Content: View>: View {
    let viewModel: ApplicationViewModel
    @ViewBuilder let content: () -> Content

    init(
        viewModel: ApplicationViewModel = ApplicationViewModel(),
        content: @escaping () -> Content
    ) {
        self.viewModel = viewModel
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(viewModel)
    }
}

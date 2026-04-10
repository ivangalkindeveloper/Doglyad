import DoglyadUI
import Router
import SwiftUI

struct TemplateListScreen: View {
    @Environment(DependencyContainer.self) private var container
    @EnvironmentObject private var router: DRouter
    let arguments: TemplateListScreenArguments?

    var body: some View {
        TemplateListScreenView(
            viewModel: TemplateListViewModel(
                container: container,
                router: router
            )
        )
    }
}

#Preview {
    TemplateListScreen(
        arguments: nil
    )
    .previewable()
}

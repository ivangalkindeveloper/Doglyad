import DoglyadUI
import Router
import SwiftUI

struct TemplateListScreen: View {
    @EnvironmentObject private var container: DependencyContainer
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

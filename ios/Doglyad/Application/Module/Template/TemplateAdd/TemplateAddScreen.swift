import DoglyadUI
import Router
import SwiftUI

struct TemplateAddScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DMessager.self) private var messager
    @EnvironmentObject private var router: DRouter
    let arguments: TemplateAddScreenArguments?

    var body: some View {
        TemplateAddScreenView(
            viewModel: TemplateAddViewModel(
                container: container,
                router: router,
                messager: messager
            )
        )
    }
}

#Preview {
    TemplateAddScreen(
        arguments: nil
    )
    .previewable()
}

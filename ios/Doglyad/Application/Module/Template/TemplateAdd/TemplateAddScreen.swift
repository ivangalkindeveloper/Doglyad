import DoglyadUI
import Router
import SwiftUI

struct TemplateAddScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
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

import DoglyadUI
import Router
import SwiftUI

struct TemplateEditScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DMessager.self) private var messager
    @EnvironmentObject private var router: DRouter
    let arguments: TemplateEditScreenArguments

    var body: some View {
        TemplateEditScreenView(
            viewModel: TemplateEditViewModel(
                container: container,
                router: router,
                messager: messager,
                arguments: arguments
            )
        )
    }
}

#Preview {
    TemplateEditScreen(
        arguments: TemplateEditScreenArguments(
            templateId: ""
        )
    )
    .previewable()
}

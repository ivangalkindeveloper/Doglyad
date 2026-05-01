import DoglyadUI
import Router
import SwiftUI

struct TemplateEditScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
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
            templateId: UUID()
        )
    )
    .previewable()
}

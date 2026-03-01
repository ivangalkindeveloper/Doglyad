import DoglyadUI
import Router
import SwiftUI

@MainActor
final class RecievedConclusionViewModel: ObservableObject {
    private let messager: DMessager
    private let router: DRouter
    private let arguments: RecievedConclusionBottomSheetArguments

    init(
        messager: DMessager,
        router: DRouter,
        arguments: RecievedConclusionBottomSheetArguments
    ) {
        self.messager = messager
        self.router = router
        self.arguments = arguments
    }

    @Published var isAppeared = false

    var conclusionResponse: String {
        arguments.conclusion.actualModelConclusion.response
    }

    func onAppear() {
        isAppeared = true
    }

    func onTapCopy() {
        UIPasteboard.general.string = conclusionResponse
        messager.show(
            type: .success,
            title: .conclusionModelResponseCopyMessageTitle,
            description: .conclusionModelResponseCopyMessageDescription
        )
    }

    func onTapConclusion() {
        router.dismissSheet()
        router.push(
            route: RouteScreen(
                type: .conclusion,
                arguments: ConclusionScreenArguments(
                    conclusion: arguments.conclusion
                )
            )
        )
    }
}

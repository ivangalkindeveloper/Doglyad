import DoglyadUI
import Router
import SwiftUI

@MainActor
final class RecievedConclusionViewModel: BaseViewModel {
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

    @Published var displayedResponse = ""
    private var typewriterTask: Task<Void, Never>?

    var model: USExaminationModelConclusion {
        arguments.conclusion.actualModelConclusion
    }

    var response: String {
        arguments.conclusion.actualModelConclusion.response
    }

    override func onInit() {
        startTypewriterAnimation()
    }

    private func startTypewriterAnimation() {
        typewriterTask?.cancel()
        let words = response.components(separatedBy: " ")
        typewriterTask = Task {
            for (index, word) in words.enumerated() {
                if Task.isCancelled { return }
                let separator = index == 0 ? "" : " "
                withAnimation(.easeIn(duration: 0.1)) {
                    displayedResponse.append(separator + word)
                }
                try? await Task.sleep(nanoseconds: 40_000_000)
            }
        }
    }

    func onTapCopy() {
        UIPasteboard.general.string = response
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

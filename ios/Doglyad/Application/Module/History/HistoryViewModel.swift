import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
final class HistoryViewModel: BaseViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
    }

    override func onInit() {
        handle {
            self.conclusions = await self.container.ultrasoundConclusionRepository.getConclusions()
        }
    }

    @Published var conclusions: [USExaminationConclusion] = []

    func onTapBack() {
        router.pop()
    }

    func onTapConclusion(
        value: USExaminationConclusion
    ) {
        router.push(
            route: RouteScreen(
                type: .conclusion,
                arguments: ConclusionScreenArguments(
                    conclusion: value
                )
            )
        )
    }
}

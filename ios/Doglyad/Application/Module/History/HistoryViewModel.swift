import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
final class HistoryViewModel: DViewModel {
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
            let conclusions = await self.container.ultrasoundConclusionRepository
                .getConclusions()
                .sorted { $0.date > $1.date }
            self.conclusions = conclusions
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

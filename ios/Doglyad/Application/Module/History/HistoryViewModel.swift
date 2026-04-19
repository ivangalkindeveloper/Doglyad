import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
@Observable
final class HistoryViewModel: Handler<DHttpApiError, DHttpConnectionError> {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
    }

    func onInit() {
        handle {
            self.conclusions = await self.container.ultrasoundConclusionRepository.getConclusions()
        }
    }

    var conclusions: [USExaminationConclusion] = []

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

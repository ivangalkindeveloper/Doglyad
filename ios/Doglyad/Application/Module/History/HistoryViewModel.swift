import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class HistoryViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
        onInit()
    }

    var conclusions: [USExaminationConclusion] = []

    private func onInit() {
        let conclusions = container.ultrasoundConclusionRepository.getConclusions()
        self.conclusions = conclusions
    }

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

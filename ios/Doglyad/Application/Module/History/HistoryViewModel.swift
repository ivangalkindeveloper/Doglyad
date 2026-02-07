import Foundation
import Router
import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter

    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        self.load()
    }

    @Published var conclusions: [ResearchConclusion] = []

    private func load() {
        let conclusions = diagnosticRepository.getConclusions()
        self.conclusions = conclusions
    }

    func onTapBack() {
        router.pop()
    }

    func onTapConclusion(
        value: ResearchConclusion
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

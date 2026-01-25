import Foundation
import SwiftUI
import Router

@MainActor
final class HistoryViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter
    
    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter,
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        loadConclusions()
    }
    
    @Published var conclusions: [ResearchConclusion] = []
    
    private func loadConclusions() -> Void {
        let conclusions = diagnosticRepository.getConclusions()
        self.conclusions = conclusions
    }
    
    func onTapBack() -> Void {
        router.pop()
    }
    
    func onTapConclusion(
        value: ResearchConclusion
    ) -> Void {
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

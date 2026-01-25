import SwiftUI

@MainActor
final class ConclusionViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter
    
    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter,
        initialConclusion: ResearchConclusion
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        self._conclusion = .init(initialValue: initialConclusion)
    }
    
    @Published var conclusion: ResearchConclusion
    
    func onTapBack() -> Void {
        router.pop()
    }
    
    func onTapShare() -> Void {}
    
    func onTapRepeatScan(
        proxy: ScrollViewProxy
    ) -> Void {}
}

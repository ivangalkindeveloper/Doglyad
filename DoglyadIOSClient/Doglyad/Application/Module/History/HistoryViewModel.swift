import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    private var diagnosticRepository: DiagnosticsRepositoryProtocol
    private var router: DRouter
    
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
        
    }
    
    func onTapBack() -> Void {
        router.pop()
    }
}

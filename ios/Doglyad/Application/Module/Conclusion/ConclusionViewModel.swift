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
        _conclusion = .init(initialValue: initialConclusion)
    }

    @Published var conclusion: ResearchConclusion

    func onTapBack() {
        router.pop()
    }

    func onTapShare() {}

    func onTapRepeatScan(
        proxy _: ScrollViewProxy
    ) {}
}

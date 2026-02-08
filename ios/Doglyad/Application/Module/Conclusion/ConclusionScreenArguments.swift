import Router

final class ConclusionScreenArguments: RouteArgumentsProtocol {
    let conclusion: ResearchConclusion

    init(
        conclusion: ResearchConclusion
    ) {
        self.conclusion = conclusion
    }
}

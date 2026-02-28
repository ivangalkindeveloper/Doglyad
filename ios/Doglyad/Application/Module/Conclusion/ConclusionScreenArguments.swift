import Router

final class ConclusionScreenArguments: RouteArgumentsProtocol {
    let conclusion: USExaminationConclusion

    init(
        conclusion: USExaminationConclusion
    ) {
        self.conclusion = conclusion
    }
}

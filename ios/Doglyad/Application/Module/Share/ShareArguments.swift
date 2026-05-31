import Router

final class ShareArguments: RouteArgumentsProtocol {
    let conclusion: USExaminationConclusion

    init(
        conclusion: USExaminationConclusion
    ) {
        self.conclusion = conclusion
    }
}

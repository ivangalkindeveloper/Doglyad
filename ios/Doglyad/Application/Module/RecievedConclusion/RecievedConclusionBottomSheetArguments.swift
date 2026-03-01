import Router

final class RecievedConclusionBottomSheetArguments: RouteArgumentsProtocol {
    let conclusion: USExaminationConclusion

    init(
        conclusion: USExaminationConclusion
    ) {
        self.conclusion = conclusion
    }
}

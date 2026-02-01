public protocol DDatabaseProtocol: AnyObject {
    // MARK: OnBoarding -

    func getOnBoardingCompleted() -> Bool

    func setOnBoardingCompleted(value: Bool)

    // MARK: ResearchType -

    func getSelectedUSResearchType() -> String?

    func setSelectedUSResearchType(value: String)

    // MARK: ModelConclusion -

    @MainActor func getResearchConclusions() -> [ResearchConclusionDB]

    @MainActor func setResearchConclusion(
        value: ResearchConclusionDB
    )

    @MainActor func updateResearchConclusion(
        value: ResearchConclusionDB
    )
}

public protocol DDatabaseProtocol: AnyObject {
    // MARK: OnBoarding -

    func getOnBoardingCompleted() -> Bool

    func setOnBoardingCompleted(value: Bool)

    // MARK: USExaminationType -

    func getSelectedUSExaminationTypeId() -> String?

    func setSelectedUSExaminationTypeId(value: String)

    // MARK: USExaminationNeuralModel -

    func getSelectedUSExaminationNeuralModelId() -> String?

    func setSelectedUSExaminationNeuralModelId(value: String)

    // MARK: NeuralModelSettings -

    func getNeuralModelResponseTemplate() -> String?

    func setNeuralModelResponseTemplate(value: String?)

    func getNeuralModelResponseLength() -> Int?

    func setNeuralModelResponseLength(value: Int?)

    // MARK: ModelConclusion -

    @MainActor func getExaminationConclusions() -> [USExaminationConclusionDB]

    @MainActor func setExaminationConclusion(
        value: USExaminationConclusionDB
    )

    @MainActor func updateExaminationConclusion(
        value: USExaminationConclusionDB
    )

    @MainActor func clearAllExaminationConclusions()

    // MARK: RequestLimit -

    @MainActor func getRequestLimit() -> RequestLimitDB?

    @MainActor func setRequestLimit(value: RequestLimitDB)

    @MainActor func clearRequestLimit()

    // MARK: Clear -

    @MainActor func clearAll()
}

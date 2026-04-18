import Foundation

public protocol DDatabaseProtocol: AnyObject {
    // MARK: OnBoarding -

    func getOnBoardingCompleted() -> Bool

    func setOnBoardingCompleted(value: Bool)

    // MARK: USExaminationType -

    func getSelectedUSExaminationTypeId() -> String?

    func setSelectedUSExaminationTypeId(value: String)

    // MARK: Neural model -

    func getSelectedUSExaminationNeuralModelId() -> String?

    func setSelectedUSExaminationNeuralModelId(value: String)

    func getNeuralModelTemperature() -> Double?

    func setNeuralModelTemperature(value: Double?)

    func getNeuralModelResponseLength() -> Int?

    func setNeuralModelResponseLength(value: Int?)

    // MARK: RequestLimit -

    @MainActor func getRequestLimit() -> RequestLimitDB?

    @MainActor func setRequestLimit(value: RequestLimitDB)

    @MainActor func clearRequestLimit()

    // MARK: USExaminationTemplate -

    func getSelectedTemplateIdByExaminationType() -> [String: String]

    func setSelectedTemplateIdByExaminationType(value: [String: String])

    @MainActor func getExaminationTemplates() -> [USExaminationTemplateDB]

    @MainActor func upsertExaminationTemplate(
        value: USExaminationTemplateDB
    )

    @MainActor func deleteExaminationTemplate(id: UUID)

    @MainActor func clearAllExaminationTemplates()

    // MARK: ModelConclusion -

    @MainActor func getExaminationConclusions() -> [USExaminationConclusionDB]

    @MainActor func setExaminationConclusion(
        value: USExaminationConclusionDB
    )

    @MainActor func updateExaminationConclusion(
        value: USExaminationConclusionDB
    )

    @MainActor func clearAllExaminationConclusions()

    // MARK: Clear -

    @MainActor func clearAll()
}

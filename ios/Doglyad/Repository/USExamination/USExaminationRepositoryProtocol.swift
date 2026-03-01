import DoglyadDatabase
import Foundation

protocol USExaminationRepositoryProtocol: AnyObject {
    // MARK: USExaminationType -

    func getSelectedUSExaminationTypeId() -> String?

    func setSelectedUSExaminationTypeId(
        id: String
    )

    // MARK: Conclusion -

    func generateConclusion(
        request: USExaminationRequest,
        locale: Locale
    ) async throws -> USExaminationModelConclusion

    @MainActor func getConclusions() -> [USExaminationConclusion]

    @MainActor func setConclusion(
        conclusion: USExaminationConclusion
    )

    @MainActor func updateConclusion(
        conclusion: USExaminationConclusion
    )

    @MainActor func clearAllConclusions()

    // MARK: Common -

    @MainActor func clearAll()
}

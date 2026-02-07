import DoglyadDatabase
import Foundation

protocol DiagnosticsRepositoryProtocol: AnyObject {
    // MARK: ResearchType -

    func getSelectedResearchType() -> ResearchType?

    func setSelectedResearchType(
        type: ResearchType
    )

    // MARK: Conclusion -

    func generateConclusion(
        request: ResearchRequest,
        locale: Locale
    ) async throws -> ResearchModelConclusion

    @MainActor func getConclusions() -> [ResearchConclusion]

    @MainActor func setConclusion(
        conclusion: ResearchConclusion
    )

    @MainActor func updateConclusion(
        conclusion: ResearchConclusion
    )
}

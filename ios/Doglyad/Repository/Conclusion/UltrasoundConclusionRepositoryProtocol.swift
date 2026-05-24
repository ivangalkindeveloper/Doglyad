import DoglyadDatabase
import Foundation

protocol UltrasoundConclusionRepositoryProtocol: AnyObject {
    // MARK: ExaminationType -

    func getSelectedExaminationTypeId() -> String?

    func setSelectedExaminationTypeId(
        id: String
    )

    // MARK: Conclusion -

    func generateConclusion(
        locale: Locale,
        request: USExaminationRequest,
        scanPhotoEncodingOptions: ScanPhotoEncodingOptions
    ) async throws -> USExaminationModelConclusion

    func sendEmail(
        email: USExaminationEmail
    ) async throws

    func getConclusions() async -> [USExaminationConclusion]

    func setConclusion(
        conclusion: USExaminationConclusion
    ) async

    func updateConclusion(
        conclusion: USExaminationConclusion
    ) async

    func clearAllConclusions() async

    // MARK: Common -

    @MainActor func clearAll() async
}

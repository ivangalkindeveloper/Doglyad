import DoglyadDatabase
import DoglyadNetwork
import Foundation

final class UltrasoundConclusionRepository: UltrasoundConclusionRepositoryProtocol {
    let database: DDatabaseProtocol
    let httpClient: DHttpClientProtocol

    init(
        database: DDatabaseProtocol,
        httpClient: DHttpClientProtocol
    ) {
        self.database = database
        self.httpClient = httpClient
    }
}

// MARK: ExaminationType -

extension UltrasoundConclusionRepository {
    func getSelectedExaminationTypeId() -> String? {
        database.getSelectedUSExaminationTypeId()
    }

    func setSelectedExaminationTypeId(
        id: String
    ) {
        database.setSelectedUSExaminationTypeId(
            value: id
        )
    }
}

// MARK: Conclusion -

extension UltrasoundConclusionRepository {
    static var conclusionEndpoint: String = "/ultrasound_conclusion"

    func generateConclusion(
        locale: Locale,
        request: USExaminationRequest,
        scanPhotoEncodingOptions: ScanPhotoEncodingOptions
    ) async throws -> USExaminationModelConclusion {
        try await httpClient.post(
            endPoint: UltrasoundConclusionRepository.conclusionEndpoint,
            body: request,
            headers: [
                DHttpHeader.acceptLanguage: locale.identifier,
            ],
            encoderUserInfo: [
                .scanPhotoEncodingOptions: scanPhotoEncodingOptions,
            ]
        )
    }

    @MainActor func getConclusions() -> [USExaminationConclusion] {
        database.getExaminationConclusions().map { USExaminationConclusion.fromDB($0) }
    }

    @MainActor func setConclusion(
        conclusion: USExaminationConclusion
    ) {
        database.setExaminationConclusion(value: conclusion.toDB())
    }

    @MainActor func updateConclusion(
        conclusion: USExaminationConclusion
    ) {
        database.updateExaminationConclusion(value: conclusion.toDB())
    }

    @MainActor func clearAllConclusions() {
        database.clearAllExaminationConclusions()
    }
}

// MARK: Common -

extension UltrasoundConclusionRepository {
    @MainActor func clearAll() {
        database.clearAll()
    }
}

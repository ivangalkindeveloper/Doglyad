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

    func getConclusions() async -> [USExaminationConclusion] {
        await database.examinationConclusions.fetchExaminationConclusions { models in
            models.map { USExaminationConclusion.fromDB($0) }
        }
    }

    func setConclusion(
        conclusion: USExaminationConclusion
    ) async {
        await database.examinationConclusions.setExaminationConclusion(
            value: conclusion.toDB()
        )
    }

    func updateConclusion(
        conclusion: USExaminationConclusion
    ) async {
        await database.examinationConclusions.updateExaminationConclusion(
            value: conclusion.toDB()
        )
    }

    func clearAllConclusions() async {
        await database.examinationConclusions.clearAllExaminationConclusions()
    }
}

// MARK: Common -

extension UltrasoundConclusionRepository {
    @MainActor func clearAll() async {
        await database.clearAll()
    }
}

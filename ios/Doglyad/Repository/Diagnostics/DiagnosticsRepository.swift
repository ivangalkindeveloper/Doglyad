import DoglyadDatabase
import DoglyadNetwork
import Foundation

final class DiagnosticsRepository: DiagnosticsRepositoryProtocol {
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

// MARK: USExaminationType -

extension DiagnosticsRepository {
    func getSelectedUSExaminationTypeId() -> String? {
        database.getSelectedUSExaminationTypeId()
    }

    func setSelectedUSExaminationTypeId(
        id: String
    ) {
        database.setSelectedUSExaminationTypeId(
            value: id
        )
    }
}

// MARK: Conclusion -

extension DiagnosticsRepository {
    static var conclusionEndpoint: String = "/ultrasound_conclusion"

    func generateConclusion(
        request: USExaminationRequest,
        locale: Locale
    ) async throws -> USExaminationModelConclusion {
        try await httpClient.post(
            endPoint: DiagnosticsRepository.conclusionEndpoint,
            body: request,
            headers: [
                DHttpHeader.acceptLanguage: locale.identifier,
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

extension DiagnosticsRepository {
    @MainActor func clearAll() {
        database.clearAll()
    }
}

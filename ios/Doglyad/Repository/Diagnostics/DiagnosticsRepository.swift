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

// MARK: ResearchType -

extension DiagnosticsRepository {
    func getSelectedResearchType() -> ResearchType? {
        ResearchType.fromString(
            database.getSelectedUSResearchType()
        )
    }

    func setSelectedResearchType(
        type: ResearchType
    ) {
        database.setSelectedUSResearchType(
            value: type.rawValue
        )
    }
}

// MARK: Conclusion -

extension DiagnosticsRepository {
    static var conclusionEndpoint: String = "/conclusion"

    func generateConclusion(
        request: ResearchRequest,
        locale: Locale
    ) async throws -> ResearchModelConclusion {
        try await httpClient.post(
            endPoint: DiagnosticsRepository.conclusionEndpoint,
            body: request,
            headers: [
                DHttpHeader.acceptLanguage: locale.identifier,
            ]
        )
    }

    @MainActor func getConclusions() -> [ResearchConclusion] {
        database.getResearchConclusions().map { ResearchConclusion.fromDB($0) }
    }

    @MainActor func setConclusion(
        conclusion: ResearchConclusion
    ) {
        database.setResearchConclusion(value: conclusion.toDB())
    }

    @MainActor func updateConclusion(
        conclusion: ResearchConclusion
    ) {
        database.updateResearchConclusion(value: conclusion.toDB())
    }
}

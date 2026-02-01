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
            self.database.getSelectedUSResearchType()
        )
    }

    func setSelectedResearchType(
        type: ResearchType
    ) {
        self.database.setSelectedUSResearchType(
            value: type.rawValue
        )
    }
}

// MARK: Conclusion -

extension DiagnosticsRepository {
    static var conclusionEndpoint: String = "/conclusion"

    func generateConclusion(
        researchData: ResearchData,
        locale: Locale,
    ) async throws -> ResearchModelConclusion {
        try await self.httpClient.post(
            endPoint: DiagnosticsRepository.conclusionEndpoint,
            body: researchData,
            headers: [
                DHttpHeader.acceptLanguage: locale.identifier
            ]
        )
    }

    @MainActor func getConclusions() -> [ResearchConclusion] {
        self.database.getResearchConclusions().map { ResearchConclusion.fromDB($0) }
    }

    @MainActor func setConclusion(
        conclusion: ResearchConclusion
    ) {
        self.database.setResearchConclusion(value: conclusion.toDB())
    }

    @MainActor func updateConclusion(
        conclusion: ResearchConclusion
    ) {
        self.database.updateResearchConclusion(value: conclusion.toDB())
    }
}

import DoglyadDatabase
import DoglyadNetwork
import Foundation

protocol DiagnosticsRepositoryProtocol {
    static var conclusionEndpoint: String { get }
    
    // MARK: ResearchType -
    func getSelectedResearchType() -> ResearchType?
    
    func setSelectedResearchType(
        type: ResearchType
    ) -> Void
    
    // MARK: Conclusion -
    func generateConclusion(
        researchData: ResearchData,
        locale: Locale,
    ) async throws -> ResearchModelConclusion
    
    func setConclusion(
        conclusion: ResearchConclusion
    ) -> Void
    
    func getConclusions() -> [ResearchConclusion]
}

final class DiagnosticsRepository: DiagnosticsRepositoryProtocol {
    static var conclusionEndpoint: String = "/conclusion"
    
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
    ) -> Void {
        database.setSelectedUSResearchType(
            value: type.rawValue
        )
    }
}

// MARK: Conclusion -
extension DiagnosticsRepository {
    func generateConclusion(
        researchData: ResearchData,
        locale: Locale,
    ) async throws -> ResearchModelConclusion {
        try await httpClient.post(
            endPoint: DiagnosticsRepository.conclusionEndpoint,
            body: researchData,
            headers: [
                "Accept-Language": locale.identifier
            ]
        )
    }
    
    func setConclusion(
        conclusion: ResearchConclusion
    ) -> Void {}
    
    func getConclusions() -> [ResearchConclusion] { [] }
}

import Foundation

public protocol DResearchNeuralModelProtocol {
    
    func parseResearchSpeech(
        locale: Locale,
        text: String
    ) async throws -> DResearchNeuralModelResponse
    
}

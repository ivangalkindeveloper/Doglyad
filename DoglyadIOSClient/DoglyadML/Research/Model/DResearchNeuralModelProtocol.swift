import Foundation

public protocol DResearchNeuralModelProtocol {
    static var isAvailable: Bool { get }
    
    func parseResearchSpeech(
        locale: Locale,
        text: String
    ) async throws -> DResearchNeuralModelResponse
}

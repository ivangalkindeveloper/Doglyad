import Foundation

public protocol DResearchNeuralModelProtocol {
    static var isAvailable: Bool { get }
    
    func parseResearchSpeech(
        locale: Locale,
        speech: String
    ) async throws -> DResearchNeuralModelResponse
}

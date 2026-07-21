import Foundation

public enum DExaminationNeuralModelError: Error {
    case unavailable
    case resourceNotFound
    case responseIsNotJSON
}

public protocol DExaminationNeuralModelProtocol {
    static func isAvailable(
        parameters: DExaminationGenerationParameters
    ) -> Bool

    init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) async throws

    func parseSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse
}

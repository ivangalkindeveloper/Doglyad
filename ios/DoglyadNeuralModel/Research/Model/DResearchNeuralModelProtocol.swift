import Foundation

public enum DExaminationNeuralModelError: Error {
    case resourceNotFound
    case responseIsNotJSON
}

public protocol DExaminationNeuralModelProtocol {
    init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) async throws

    static var isAvailable: Bool { get }

    func parseExaminationSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse
}

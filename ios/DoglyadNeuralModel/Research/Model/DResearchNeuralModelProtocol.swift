import Foundation

public protocol DExaminationNeuralModelProtocol {
    static var isAvailable: Bool { get }

    func parseExaminationSpeech(
        locale: Locale,
        speech: String
    ) async throws -> DExaminationNeuralModelResponse
}

import Foundation

public struct DExaminationGenerationParameters {
    public let temperature: Double
    public let maxTokens: Int

    public init(
        temperature: Double,
        maxTokens: Int
    ) {
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

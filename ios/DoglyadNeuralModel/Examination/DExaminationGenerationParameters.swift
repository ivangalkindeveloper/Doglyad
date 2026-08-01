import Foundation

public struct DExaminationGenerationParameters: Sendable {
    /// Model temperature
    public let temperature: Double
    /// The response generation limit.
    public let maxTokens: Int
    /// The context size limit: system prompt, dictation and response.
    /// It drives the KV cache estimate when checking whether the device can run the model.
    public let maxContextTokens: Int

    public init(
        temperature: Double,
        maxTokens: Int,
        maxContextTokens: Int
    ) {
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.maxContextTokens = maxContextTokens
    }
}

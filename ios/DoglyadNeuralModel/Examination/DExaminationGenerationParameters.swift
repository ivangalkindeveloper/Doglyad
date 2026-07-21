import Foundation

public struct DExaminationGenerationParameters: Sendable {
    /// Температура модели
    public let temperature: Double
    /// Предел генерации ответа.
    public let maxTokens: Int
    /// Предельный размер контекста: системный промпт, диктовка и ответ.
    /// По нему считается KV-кэш при проверке, потянет ли устройство модель.
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

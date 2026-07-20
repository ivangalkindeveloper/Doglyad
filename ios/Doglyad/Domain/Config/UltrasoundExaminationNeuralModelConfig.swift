import Foundation

struct UltrasoundExaminationNeuralModelConfig: Codable {
    private static let fallbackPromptLanguageCode = "en"

    let temperature: Double
    let maxTokens: Int
    let prompt: [String: String]

    func getPrompt(for locale: Locale) -> String? {
        let key = locale.language.languageCode?.identifier ?? Self.fallbackPromptLanguageCode
        return prompt[key] ?? prompt[Self.fallbackPromptLanguageCode]
    }
}

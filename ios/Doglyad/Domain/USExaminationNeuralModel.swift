import Foundation

struct USExaminationNeuralModel: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: [String: String]

    func getLocalizedDescription(for locale: Locale) -> LocalizedStringResource {
        let key = locale.language.languageCode?.identifier ?? "en"
        let description = description[key] ?? description.values.first ?? ""
        return LocalizedStringResource(stringLiteral: description)
    }
}

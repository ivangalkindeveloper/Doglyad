import Foundation

struct USExaminationType: Codable, Identifiable, Equatable {
    let id: String
    let title: [String: String]

    func getLocalizedTitle(for locale: Locale) -> LocalizedStringResource {
        let key = locale.language.languageCode?.identifier ?? "en"
        let title = title[key] ?? title.values.first ?? ""
        return LocalizedStringResource(stringLiteral: title)
    }
}

extension USExaminationType {
    static let `default`: Self = .init(
        id: "abdominalCavity",
        title: [
            "en_US": "Abdominal cavity",
            "ru_RU": "Брюшная полость"
        ]
    )
}

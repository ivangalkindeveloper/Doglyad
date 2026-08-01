import Foundation

/// Contextual strings for speech recognition, grouped by locale code
/// (`en`, `ru`). They hint the recognizer at examination-specific vocabulary —
/// terms, abbreviations, names — so it mishears them less often.
///
/// Delivered by the backend as an `{"en": [...], "ru": [...]}` object, so they are
/// decoded straight from a dictionary without a wrapper key.
struct USExaminationContextualStrings: Codable, Equatable {
    let strings: [String: [String]]

    init(
        strings: [String: [String]]
    ) {
        self.strings = strings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        strings = try container.decode([String: [String]].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(strings)
    }

    /// Strings for the current locale, falling back to `en` and then to an empty array.
    func getStrings(for locale: Locale) -> [String] {
        let key = locale.language.languageCode?.identifier ?? "en"
        return strings[key] ?? strings["en"] ?? []
    }
}

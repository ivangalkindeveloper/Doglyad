import Foundation

/// Контекстные строки для распознавания речи, сгруппированные по коду локали
/// (`en`, `ru`). Подсказывают распознавателю специфичную лексику осмотра —
/// термины, сокращения, названия — чтобы он реже ошибался на них.
///
/// Приходят с бэкенда объектом `{"en": [...], "ru": [...]}`, поэтому декодируются
/// напрямую из словаря без обёртки-ключа.
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

    /// Строки для текущей локали с откатом на `en`, затем на пустой массив.
    func getStrings(for locale: Locale) -> [String] {
        let key = locale.language.languageCode?.identifier ?? "en"
        return strings[key] ?? strings["en"] ?? []
    }
}

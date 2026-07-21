import Foundation

/// Создаёт контроллер распознавания речи.
///
/// Выбор реализации зависит не только от версии iOS, но и от поддержки локали
/// в `SpeechTranscriber` (например, `ru-RU` там нет), а список локалей отдаётся
/// асинхронно — поэтому «лучшая» реализация подбирается в `make(locale:)` через
/// `await`. Для мгновенного старта экрана есть синхронный `makeDefault(locale:)`.
public enum DSpeechFactory {
    /// Синхронный контроллер по умолчанию — всегда доступный `SFSpeechRecognizer`.
    /// Годится как стартовое значение, пока идёт асинхронный подбор лучшего.
    @MainActor
    public static func makeDefault(
        locale: Locale
    ) -> any DSpeechControllerProtocol {
        DSpeechControllerSFSpeechRecognizer(locale: locale)
    }

    /// Лучшая доступная реализация: на iOS 26+ — `SpeechAnalyzer`, если он реально
    /// поддерживает локаль; иначе — `SFSpeechRecognizer`.
    @MainActor
    public static func make(
        locale: Locale
    ) async -> any DSpeechControllerProtocol {
        if #available(iOS 26.0, *),
           await DSpeechControllerAnalyzer.isSupported(locale: locale)
        {
            return DSpeechControllerAnalyzer(locale: locale)
        }

        return DSpeechControllerSFSpeechRecognizer(locale: locale)
    }
}

import Foundation

public enum DSpeechFactory {
    @MainActor
    public static func makeDefault(
        locale: Locale,
        contextualStrings: [String]
    ) -> any DSpeechControllerProtocol {
        DSpeechControllerSFSpeechRecognizer(locale: locale, contextualStrings: contextualStrings)
    }

    @MainActor
    public static func make(
        locale: Locale,
        contextualStrings: [String]
    ) async -> any DSpeechControllerProtocol {
        if #available(iOS 26.0, *),
           await DSpeechControllerAnalyzer.isSupported(locale: locale)
        {
            return DSpeechControllerAnalyzer(locale: locale, contextualStrings: contextualStrings)
        }

        return DSpeechControllerSFSpeechRecognizer(locale: locale, contextualStrings: contextualStrings)
    }
}

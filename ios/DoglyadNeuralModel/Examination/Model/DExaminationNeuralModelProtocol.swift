import Foundation

public enum DExaminationNeuralModelError: Error {
    case unavailable
    case resourceNotFound
    case responseIsNotJSON
}

public protocol DExaminationNeuralModelProtocol {
    /// Доступность реализации. Локаль важна не меньше системы: модель может быть
    /// установлена, но не знать язык диктовки, и тогда разбирать ею нельзя.
    static func isAvailable(
        locale: Locale,
        parameters: DExaminationGenerationParameters
    ) -> Bool

    init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) async throws

    /// Прогревает модель, чтобы первый разбор не платил за инициализацию.
    /// Вызывается, когда врач начинает диктовать: пока он говорит, есть время.
    func prewarm()

    func parseSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse
}

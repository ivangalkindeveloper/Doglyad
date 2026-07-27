import Foundation
import FoundationModels

@available(iOS 26.0, *)
public final class DExaminationNeuralModelFoundationModels: DExaminationNeuralModelProtocol {
    @FoundationModels.Generable
    struct Response {
        @FoundationModels.Guide(description: "Patient name, number, or nickname")
        let patientName: String?

        @FoundationModels.Guide(description: "Patient gender")
        let patientGender: Gender?

        @FoundationModels.Guide(description: "Patient date of birth in the following format \(DExaminationGenerationConfig.promptDateFormat)")
        let patientDateOfBirth: String?

        @FoundationModels.Guide(description: "Patient height in centimeters")
        let patientHeightCM: Double?

        @FoundationModels.Guide(description: "Patient weight in kilograms")
        let patientWeightKG: Double?

        @FoundationModels.Guide(description: "Patient complaints")
        let patientComplaint: String?

        @FoundationModels.Guide(description: "Examination description, including any technical details such as device model, probe types, and the number of saved photographs and videos")
        let examinationDescription: String?
    }

    @FoundationModels.Generable
    enum Gender {
        case male
        case female
    }

    public static func isAvailable(
        locale: Locale,
        parameters _: DExaminationGenerationParameters
    ) -> Bool {
        let model = SystemLanguageModel.default
        guard model.isAvailable else { return false }

        // Системная модель покрывает не все языки приложения, но остаётся
        // «доступной» и на непокрытых. Без этой проверки мы предпочли бы её MLX
        // на локали, языка которой она не знает. Набор языков меняется между
        // релизами системы, поэтому спрашиваем в рантайме, а не держим список.
        guard let languageCode = locale.language.languageCode else { return false }

        return model.supportedLanguages.contains { $0.languageCode == languageCode }
    }

    private let systemPrompt: String
    private let generationOptions: GenerationOptions
    /// Сессия, прогретая под ближайший разбор. Заводим её заранее: на первом
    /// обращении модель компилирует схему ответа и поднимает guardrails, и без
    /// прогрева эта задержка достаётся врачу уже после диктовки.
    private var prewarmedSession: LanguageModelSession?
    /// `parseSpeech` и `prewarm` вызываются из разных контекстов, а сессию
    /// приходится подменять, поэтому доступ к ней закрыт замком.
    private let lock = NSLock()

    public init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) {
        self.systemPrompt = systemPrompt
        generationOptions = GenerationOptions(
            temperature: parameters.temperature,
            maximumResponseTokens: parameters.maxTokens
        )
    }

    public func prewarm() {
        lock.lock()
        defer { lock.unlock() }

        guard prewarmedSession == nil else { return }

        let session = LanguageModelSession(instructions: systemPrompt)
        session.prewarm()
        prewarmedSession = session
    }

    /// Забирает прогретую сессию под текущий разбор. Синхронно — замок нельзя
    /// удерживать через `await`.
    ///
    /// Каждая диктовка разбирается независимо, а сессия копит транскрипт,
    /// поэтому прогретую забираем целиком, а следующий `prewarm` заведёт новую.
    private func takeSession() -> LanguageModelSession {
        lock.lock()
        defer { lock.unlock() }

        let session = prewarmedSession ?? LanguageModelSession(instructions: systemPrompt)
        prewarmedSession = nil

        return session
    }

    public func parseSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse {
        let session = takeSession()
        let response = try await session.respond(
            to: speech,
            generating: Response.self,
            options: generationOptions
        )

        return DExaminationNeuralModelResponse.fromFoudationModels(
            response.content
        )
    }
}

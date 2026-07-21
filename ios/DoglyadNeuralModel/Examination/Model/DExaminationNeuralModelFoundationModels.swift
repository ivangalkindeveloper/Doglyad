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

        @FoundationModels.Guide(description: "Patient examination description")
        let examinationDescription: String?

        @FoundationModels.Guide(description: "Additional patient-independent examination details, such as device model, sensor types, and number of photographs and videos")
        let additionalData: String?
    }

    @FoundationModels.Generable
    enum Gender {
        case male
        case female
    }

    public static func isAvailable(
        parameters _: DExaminationGenerationParameters
    ) -> Bool {
        SystemLanguageModel.default.isAvailable
    }

    private let systemPrompt: String
    private let generationOptions: GenerationOptions

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

    public func parseSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse {
        let session = LanguageModelSession(
            instructions: systemPrompt
        )
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

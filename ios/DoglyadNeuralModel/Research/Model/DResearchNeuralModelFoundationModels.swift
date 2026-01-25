import Foundation
import FoundationModels

@available(iOS 26.0, *)
public final class DResearchNeuralModelFoundationModels: DResearchNeuralModelProtocol {
    @FoundationModels.Generable
    struct Response {
        @FoundationModels.Guide(description: "Patient name, number, or nickname")
        let patientName: String?
        
        @FoundationModels.Guide(description: "Patient gender")
        let patientGender: Gender?
        
        @FoundationModels.Guide(description: "Patient date of birth in the following format \(DResearchGenerationConfig.dateFormat)")
        let patientDateOfBirth: String?
        
        @FoundationModels.Guide(description: "Patient height in centimeters")
        let patientHeightCM: Double?
        
        @FoundationModels.Guide(description: "Patient weight in kilograms")
        let patientWeightKG: Double?
        
        @FoundationModels.Guide(description: "Patient complaints")
        let patientComplaint: String?
        
        @FoundationModels.Guide(description: "Patient examination details")
        let researchDescription: String?
        
        @FoundationModels.Guide(description: "Additional patient-independent examination details, such as device model, sensor types, and number of photographs and videos")
        let additionalData: String?
    }
    
    @FoundationModels.Generable
    enum Gender {
        case male
        case female
    }
    
    public static var isAvailable: Bool { SystemLanguageModel.default.isAvailable }
    private let session: LanguageModelSession = LanguageModelSession(
        instructions: """
        \(DResearchGenerationConfig.modelRole)
        \(DResearchGenerationConfig.answerExamples)
        """,
    )
    
    public init() {}
    
    public func parseResearchSpeech(
        locale: Locale,
        speech: String
    ) async throws -> DResearchNeuralModelResponse {
        let taskPrompt = DResearchGenerationConfig.taskPrompt(
            locale,
            DResearchGenerationConfig.testText
        )
        
        let response = try await session.respond(
            to: taskPrompt,
            generating: Response.self
        )
        
        return DResearchNeuralModelResponse.fromFoudationModels(
            response.content
        )
    }
}

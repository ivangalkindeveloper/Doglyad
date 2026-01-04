import Foundation
import FoundationModels

@available(iOS 26.0, *)
public final class DResearchNeuralModelFoundationModels: DResearchNeuralModelProtocol {
    public static var isAvailable: Bool { SystemLanguageModel.default.isAvailable }

    @FoundationModels.Generable
    struct Response {
        @FoundationModels.Guide(description: "")
        let patientName: String?
        
        @FoundationModels.Guide(description: "")
        let patientGender: Gender?
        
        @FoundationModels.Guide(description: "")
        let patientDateOfBirth: String?
        
        @FoundationModels.Guide(description: "")
        let patientHeight: Double?
        
        @FoundationModels.Guide(description: "")
        let patientWeight: Double?
        
        @FoundationModels.Guide(description: "")
        let patientComplaint: String?
        
        @FoundationModels.Guide(description: "")
        let researchDescription: String?
        
        @FoundationModels.Guide(description: "")
        let additionalData: String?
    }
    
    @FoundationModels.Generable
    enum Gender {
        case male
        case female
    }
    
    public init() {}
    
    public func parseResearchSpeech(
        locale: Locale,
        text: String
    ) async throws -> DResearchNeuralModelResponse {
        let session = LanguageModelSession(
            instructions: DResearchGenerationConfig.modelRole
        )
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

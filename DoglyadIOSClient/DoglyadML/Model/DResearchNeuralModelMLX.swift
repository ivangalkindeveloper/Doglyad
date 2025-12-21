import Foundation
internal import AnyLanguageModel

public final class DResearchNeuralModelMLX: DResearchNeuralModelProtocol {
    
    public init() {}
    
    public func parseResearchSpeech(
        locale: Locale,
        text: String
    ) async throws -> DResearchNeuralModelResponse {
        let model = MLXLanguageModel(
            modelId: DResearchGenerationConfig.mlxModelId
        )
        let session = LanguageModelSession(
            model: model,
            instructions: DResearchGenerationConfig.modelRole
        )
        
        let taskPrompt = DResearchGenerationConfig.taskPrompt(
            locale,
            DResearchGenerationConfig.testText
        )

        let response = try await session.respond(
            to:
                """
                \(DResearchGenerationConfig.modelRole)
                
                \(DResearchGenerationConfig.jsonFormat)
                
                \(taskPrompt)
                """,
        )
        
        return DResearchNeuralModelResponse(
            patientName: nil,
            patientGender: nil,
            patientDateOfBirth: nil,
            patientHeight: nil,
            patientWeight: nil,
            patientComplaint: nil,
            researchDescription: nil,
            additionalData: nil,
        )
    }
    
}

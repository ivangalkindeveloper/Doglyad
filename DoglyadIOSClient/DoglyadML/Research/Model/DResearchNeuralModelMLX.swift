import Foundation
internal import MLXLMCommon
internal import MLX

public final class DResearchNeuralModelMLX: DResearchNeuralModelProtocol {
    public static let defaultModel = DNeuralModelData(
        modelId: "mlx-community/Qwen2.5-0.5B-Instruct-4bit",
        params: 500_000_000, // 0.5B
        quantBits: 4,
        hiddenSize: 896,
        numLayers: 24
    )
    public static var isAvailable: Bool {
        DNeuralDevice.canRunLocally(model: defaultModel, maxTokens: 512)
    }

    public init() {}

    public func parseResearchSpeech(
        locale: Locale,
        text: String
    ) async throws -> DResearchNeuralModelResponse {
        let model = try await MLXLMCommon.loadModel(id: DResearchNeuralModelMLX.defaultModel.modelId)
        let session = MLXLMCommon.ChatSession(
            model,
            instructions: """
            \(DResearchGenerationConfig.modelRole)

            \(DResearchGenerationConfig.jsonFormat)
            """,
        )
        let taskPrompt = DResearchGenerationConfig.taskPrompt(
            locale,
            DResearchGenerationConfig.testText
        )

        let response = try await session.respond(
            to: taskPrompt,
        )

        let data = Data(response.utf8)
        let decoded = try JSONDecoder().decode(DResearchNeuralModelResponse.self, from: data)
        return decoded
    }
}

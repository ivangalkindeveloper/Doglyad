import Foundation
internal import MLXLMCommon
internal import MLX
internal import MLXLLM

public final class DResearchNeuralModelMLX: DResearchNeuralModelProtocol {
    public static var isAvailable: Bool {
        DNeuralDevice.canRunLocally(
            model: defaultModel,
            maxTokens: 512
        )
    }
    private static let defaultModel = DNeuralModelData(
        modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit",
        params: 1_500_000_000, // 1.5B
        quantBits: 4,
        hiddenSize: 896,
        numLayers: 24
    )
    private let model: MLXLMCommon.ModelContext
    private let session: MLXLMCommon.ChatSession

    public init() async throws {
        let directory: URL = Bundle.main.url(
            forResource: "mlx-Qwen2.5-1.5B-Instruct-4bit",
            withExtension: nil
        )!
        self.model = try await MLXLMCommon.loadModel(
            directory: directory,
        )
        self.session = MLXLMCommon.ChatSession(
            model,
            instructions: """
            \(DResearchGenerationConfig.modelRole)
            \(DResearchGenerationConfig.outputJsonExample)
            """,
        )
    }

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
        )

        let data = Data(response.utf8)
        let decoded = try DResearchGenerationConfig.jsonDecoder.decode(
            DResearchNeuralModelResponse.self,
            from: data
        )
        return decoded
    }
}

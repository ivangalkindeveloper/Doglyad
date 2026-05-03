import Foundation
internal import MLXLMCommon
internal import MLX
internal import MLXLLM
internal import Tokenizers

public final class DExaminationNeuralModelMLX: DExaminationNeuralModelProtocol {
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
        model = try await MLXLMCommon.loadModel(
            from: directory,
            using: DTransformersTokenizerLoader()
        )
        session = MLXLMCommon.ChatSession(
            model,
            instructions: """
            \(DExaminationGenerationConfig.modelRole)
            \(DExaminationGenerationConfig.outputJsonExample)
            """
        )
    }

    public func parseExaminationSpeech(
        locale: Locale,
        speech _: String
    ) async throws -> DExaminationNeuralModelResponse {
        let taskPrompt = DExaminationGenerationConfig.taskPrompt(
            locale,
            DExaminationGenerationConfig.testText
        )

        let response = try await session.respond(
            to: taskPrompt
        )

        let data = Data(response.utf8)
        let decoded = try DExaminationGenerationConfig.jsonDecoder.decode(
            DExaminationNeuralModelResponse.self,
            from: data
        )
        return decoded
    }
}

private struct DTransformersTokenizerLoader: MLXLMCommon.TokenizerLoader {
    func load(from directory: URL) async throws -> any MLXLMCommon.Tokenizer {
        let upstream = try await Tokenizers.AutoTokenizer.from(modelFolder: directory)
        return DTokenizerBridge(upstream)
    }
}

private struct DTokenizerBridge: MLXLMCommon.Tokenizer {
    private let upstream: any Tokenizers.Tokenizer

    init(_ upstream: any Tokenizers.Tokenizer) {
        self.upstream = upstream
    }

    func encode(text: String, addSpecialTokens: Bool) -> [Int] {
        upstream.encode(text: text, addSpecialTokens: addSpecialTokens)
    }

    func decode(tokenIds: [Int], skipSpecialTokens: Bool) -> String {
        upstream.decode(tokens: tokenIds, skipSpecialTokens: skipSpecialTokens)
    }

    func convertTokenToId(_ token: String) -> Int? {
        upstream.convertTokenToId(token)
    }

    func convertIdToToken(_ id: Int) -> String? {
        upstream.convertIdToToken(id)
    }

    var bosToken: String? { upstream.bosToken }
    var eosToken: String? { upstream.eosToken }
    var unknownToken: String? { upstream.unknownToken }

    func applyChatTemplate(
        messages: [[String: any Sendable]],
        tools: [[String: any Sendable]]?,
        additionalContext: [String: any Sendable]?
    ) throws -> [Int] {
        do {
            return try upstream.applyChatTemplate(
                messages: messages,
                tools: tools,
                additionalContext: additionalContext
            )
        } catch Tokenizers.TokenizerError.missingChatTemplate {
            throw MLXLMCommon.TokenizerError.missingChatTemplate
        }
    }
}

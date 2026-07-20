import Foundation
internal import MLXLMCommon
internal import MLX
internal import MLXLLM
internal import Tokenizers

public final class DExaminationNeuralModelMLX: DExaminationNeuralModelProtocol {
    public static var isAvailable: Bool {
        guard resourceDirectory != nil else { return false }

        return DNeuralDevice.canRunLocally(
            model: defaultModel,
            maxTokens: 512
        )
    }

    private static let resourceName = "mlx-Qwen2.5-1.5B-Instruct-4bit"
    private static var resourceDirectory: URL? {
        Bundle.main.url(
            forResource: resourceName,
            withExtension: nil
        )
    }

    private static let defaultModel = DNeuralModelData(
        modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit",
        params: 1500000000, // 1.5B
        quantBits: 4,
        hiddenSize: 896,
        numLayers: 24
    )
    private let model: MLXLMCommon.ModelContext
    private let systemPrompt: String
    private let generateParameters: MLXLMCommon.GenerateParameters

    public init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) async throws {
        guard let directory = Self.resourceDirectory else {
            throw DExaminationNeuralModelError.resourceNotFound
        }

        model = try await MLXLMCommon.loadModel(
            from: directory,
            using: DTransformersTokenizerLoader()
        )
        self.systemPrompt = systemPrompt
        generateParameters = MLXLMCommon.GenerateParameters(
            maxTokens: parameters.maxTokens,
            temperature: Float(parameters.temperature)
        )
    }

    public func parseExaminationSpeech(
        speech: String
    ) async throws -> DExaminationNeuralModelResponse {
        let session = MLXLMCommon.ChatSession(
            model,
            instructions: systemPrompt,
            generateParameters: generateParameters
        )
        let response = try await session.respond(
            to: speech
        )

        guard let json = DExaminationJSONSanitizer.extractJSONObject(from: response) else {
            throw DExaminationNeuralModelError.responseIsNotJSON
        }

        let data = Data(json.utf8)
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

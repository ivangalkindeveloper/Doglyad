import Foundation
internal import MLXLMCommon
internal import MLX
internal import MLXLLM
internal import Tokenizers

public final class DExaminationNeuralModelMLX: DExaminationNeuralModelProtocol {
    public static func isAvailable(
        parameters: DExaminationGenerationParameters
    ) -> Bool {
        DNeuralDevice.canRunLocally(
            model: defaultModel,
            weightsBytes: resourceBytes,
            maxContextTokens: parameters.maxContextTokens
        )
    }

    private static let resourceName = "mlx-Qwen2.5-1.5B-Instruct-4bit"
    private static let resourceDirectory: URL? = Bundle.main.url(
        forResource: resourceName,
        withExtension: nil
    )

    /// Размер весов меряем по факту, а не выводим из числа параметров:
    /// поквантовые scales и zeros в оценку не укладываются, а при смене
    /// модели фактический размер обновится сам.
    private static let resourceBytes: UInt64 = {
        guard let resourceDirectory else { return 0 }

        return DNeuralResource.directorySize(at: resourceDirectory)
    }()

    /// Архитектура mlx-community/Qwen2.5-1.5B-Instruct-4bit по её config.json.
    private static let defaultModel = DNeuralModelData(
        modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit",
        numLayers: 28,
        numKeyValueHeads: 2,
        headDimension: 128
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

        // Без лимита буферный кэш MLX растёт поверх весов и на телефоне
        // превращается в лишние сотни мегабайт резидентной памяти.
        MLX.Memory.cacheLimit = Self.gpuCacheLimitBytes

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

    private static let gpuCacheLimitBytes = 32 * 1024 * 1024

    deinit {
        // Веса освобождаются вместе с ModelContext, но буферный кэш MLX
        // переживает модель, поэтому сбрасываем его явно.
        MLX.Memory.clearCache()
    }

    public func parseSpeech(
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

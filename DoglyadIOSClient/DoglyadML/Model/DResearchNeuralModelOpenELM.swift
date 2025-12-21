//public final class DResearchNeuralModelOpenELM: DResearchNeuralModelProtocol {
//    private var model: StatefulMistral7BInstructInt4
//    private var tokenizer: (any Tokenizer)?
//    
//    public init() {
//        let config = MLModelConfiguration()
//        config.computeUnits = .all
////        self.model = try! StatefulMistral7BInstructInt4(configuration: config)
//    }
//    
//    public func parsePatientResearchSpeech(
//        locale: Locale,
//        text: String
//    ) async -> String {
//        let options = GenerationOptions()
//        var config = GenerationConfig(
//            maxNewTokens: options.maxNewTokens,
//            temperature: options.temperature,
//            topP: options.topP
//        )
//        config.doSample = true
//        let fullPrompt = DResearchNeuralModelData.fullPrompt(
//            locale: locale,
//            text: testText
//        )
//        
//        do {
//            let tokenizer = try await AutoTokenizer.from(
//                pretrained: DResearchNeuralModelData.tokenizerName
//            )
//            let languageModel = LanguageModel.
//            
//            var tokens = tokenizer.encode(text: fullPrompt)
//            let maxInputLength = languageModel.maxContextLength - config.maxNewTokens
//            if tokens.count > maxInputLength {
//                tokens = Array(tokens.prefix(maxInputLength))
//            }
//            let promptTokensCount = tokens.count
//            
//            await languageModel.resetState()
//            
//            let result = try await languageModel.generate(
//                config: config,
//                tokens: tokens
//            )
//            let resultTokens = Array(result)
//            let generatedTokens = resultTokens.count > promptTokensCount
//                ? Array(resultTokens.suffix(from: promptTokensCount))
//                : resultTokens
//            let decodedText = tokenizer.decode(tokens: generatedTokens)
//            
//            print("GENERATED:")
//            print(decodedText)
//            return decodedText
//        } catch {
//            print("ERROR:")
//            print(error)
//            return ""
//        }
//    }
//}

import CoreML
import Foundation
internal import Tokenizers

private let testText = "Пациент Иван мужчина родился 28 марта 1994г. рост 180 см 80 кг жалобы периодически боли животе дискомфорт при глотании боли в левом потребили и чья жесть в правом потреби исследования проведено ультразвуковой исследование органов брюшной полости а также ультразвуковой исследования почек дополнительную информацию о технических фотофактов не выявлено использован линейный да частотой 7,5 мегагерц сохранено 12 снимков исследования"

public protocol DResearchNeuralModelProtocol {
    func parsePatientResearchSpeech(
        locale: Locale,
        text: String
    ) async -> String
}

public final class DResearchNeuralModelOpenELM: DResearchNeuralModelProtocol {
    private lazy var model: DoglyadOpenELM = {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        return try! DoglyadOpenELM(configuration: config)
    }()
    private var tokenizer: (any Tokenizer)?
    
    public init() {}
    
    public func parsePatientResearchSpeech(
        locale: Locale,
        text: String
    ) async -> String {
        await Task.detached(
            priority: .high
        ) {
            do {
                let fullPrompt = DResearchNeuralModelData.fullPrompt(
                    locale: locale,
                    text: testText
                )
                let tokenizer = try await self.getTokenizer()
                
                return autoreleasepool {
                    var inputIds = self.tokenize(text: fullPrompt, tokenizer: tokenizer)
                    let sequenceLength = DResearchNeuralModelData.sequenceLength
                    if inputIds.count > sequenceLength {
                        inputIds = Array(inputIds.prefix(sequenceLength))
                    }
                    
                    let inputArray = self.createMLMultiArray(from: inputIds)
                    let input = DoglyadOpenELMInput(input_ids: inputArray)
                    
                    let prediction = try! self.model.prediction(input: input)
                    let outputIds = self.extractOutputIds(from: prediction)
                    let detokenized = self.detokenize(ids: outputIds, tokenizer: tokenizer)
                    
                    return detokenized
                }
            } catch {
                print(error)
                return ""
            }
        }.value
    }
    
    private func getTokenizer() async throws -> any Tokenizer {
        if let existing = tokenizer {
            return existing
        }
        
        let loaded = try await AutoTokenizer.from(pretrained: DResearchNeuralModelData.tokenizerName)
        tokenizer = loaded
        return loaded
    }
    
    private func tokenize(
        text: String,
        tokenizer: any Tokenizer
    ) -> [Int32] {
        let tokenIds = tokenizer.encode(text: text)
        return tokenIds.map { Int32($0) }
    }
    
    private func createMLMultiArray(
        from ids: [Int32]
    ) -> MLMultiArray {
        let shape = [1, NSNumber(value: ids.count)]
        guard let array = try? MLMultiArray(shape: shape, dataType: .int32) else {
            fatalError()
        }
        
        for (index, id) in ids.enumerated() {
            array[index] = NSNumber(value: id)
        }

        return array
    }
    
    private func extractOutputIds(
        from prediction: MLFeatureProvider
    ) -> [Int32] {
        let featureNames = prediction.featureNames
        var maxOutput: (name: String, array: MLMultiArray, count: Int)?
        for name in featureNames {
            guard let featureValue = prediction.featureValue(for: name),
                  let multiArray = featureValue.multiArrayValue else {
                continue
            }
            
            let count = multiArray.count
            if maxOutput == nil || count > maxOutput!.count {
                maxOutput = (name: name, array: multiArray, count: count)
            }
        }
        
        guard let output = maxOutput?.array else {
            fatalError("Не найден выходной параметр модели")
        }
        
        let shape = output.shape
        guard shape.count >= 2 else {
            fatalError("Неверная форма выходных данных")
        }
        
        let batchSize = shape[0].intValue
        let sequenceLength = shape[shape.count - 2].intValue
        let vocabSize = shape[shape.count - 1].intValue
        var tokenIds: [Int32] = []
        
        for seqIndex in 0 ..< sequenceLength {
            var maxValue = Float.leastNormalMagnitude
            var maxIndex = 0
            
            for vocabIndex in 0 ..< vocabSize {
                let index = seqIndex * vocabSize + vocabIndex
                let value = output[index].floatValue
                
                if value > maxValue {
                    maxValue = value
                    maxIndex = vocabIndex
                }
            }
            
            tokenIds.append(Int32(maxIndex))
        }
        
        return tokenIds
    }
    
    private func detokenize(
        ids: [Int32],
        tokenizer: any Tokenizer
    ) -> String {
        let tokens = ids.map { Int($0) }
        return tokenizer.decode(tokens: tokens)
    }
}

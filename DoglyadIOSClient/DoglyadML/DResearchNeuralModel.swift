import CoreML
import Foundation

private func fullPrompt(
    text: String
) -> String {
"""
You are a model that parses a medical study text obtained by a doctor's dictation.
This text must be parsed into the following entities: patient name, patient gender, patient date of birth, patient height, patient weight, patient complaint, study description, and additional information about the medical study performed.
The response must be returned in the JSON format described below; nothing else is required.
Each parsed section of entities must be edited for syntax and spelling errors, as the text is simply dictated verbally.

JSON format:
{
  "patientName":"Patient name",
  "patientDateOfBirth": "male / female",
  "patientHeight": 180.0,
  "patientWeight": 64,
  "patientComplaint": "Patient complaint",
  "researchDescription": "Rsearch description",
  "additionalData": "Additional data"
}

Text:
\(text)
"""
}

public protocol DResearchNeuralModelProtocol {
    func parseSpeech(
        localizedPromt: String,
        text: String
    ) -> String
}

public final class DResearchNeuralModelOpenELM: DResearchNeuralModelProtocol {
    private let model = try! DoglyadOpenELM(configuration: MLModelConfiguration())
    
    public init() {}
    
    public func parseSpeech(
        localizedPromt: String,
        text: String
    ) -> String {
        let fullPrompt = fullPrompt(text: text)
        guard let inputIds = tokenize(text: fullPrompt) else {
            return ""
        }
        guard let inputArray = createMLMultiArray(from: inputIds) else {
            return ""
        }
        
        do {
            let input = DoglyadOpenELMInput(input_ids: inputArray)
            let prediction = try model.prediction(input: input)
            guard let outputIds = extractOutputIds(from: prediction) else {
                return ""
            }
            
            return detokenize(ids: outputIds)
        } catch {
            return ""
        }
    }
    
    private func tokenize(
        text: String
    ) -> [Int32]? {
        return text.utf8.map { Int32($0) }
    }
    
    private func createMLMultiArray(
        from ids: [Int32]
    ) -> MLMultiArray? {
        let shape = [1, NSNumber(value: ids.count)]
        guard let array = try? MLMultiArray(shape: shape, dataType: .int32) else {
            return nil
        }
        
        for (index, id) in ids.enumerated() {
            array[index] = NSNumber(value: id)
        }
        
        return array
    }
    
    private func extractOutputIds(
        from prediction: MLFeatureProvider
    ) -> [Int32]? {
        let featureNames = prediction.featureNames
        guard let outputName = featureNames.first(where: { $0.contains("output") || $0.contains("logits") || $0.contains("var") }) else {
            return nil
        }
        
        guard let output = prediction.featureValue(for: outputName)?.multiArrayValue else {
            return nil
        }
        
        var ids: [Int32] = []
        let count = output.count
        for i in 0..<count {
            let value = output[i]
            ids.append(Int32(truncating: value))
        }
        
        return ids
    }
    
    private func detokenize(ids: [Int32]) -> String {
        let bytes = ids.compactMap { UInt8(exactly: $0) }
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}

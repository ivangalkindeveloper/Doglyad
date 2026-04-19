import Foundation

// MARK: NeuralModelSettings -

public protocol DDatabaseNeuralModelSettingsProtocol: AnyObject {
    func getNeuralModelTemperature() -> Double?

    func setNeuralModelTemperature(value: Double?)

    func getNeuralModelResponseLength() -> Int?

    func setNeuralModelResponseLength(value: Int?)

    func getSelectedTemplateIdByExaminationType() -> [String: String]
    
    func setSelectedTemplateIdByExaminationType(value: [String: String])
}

extension DDatabase: DDatabaseNeuralModelSettingsProtocol {
    public func getNeuralModelTemperature() -> Double? {
        getDouble(.neuralModelTemperature)
    }

    public func setNeuralModelTemperature(value: Double?) {
        if let value {
            setValue(value, .neuralModelTemperature)
        } else {
            removeValue(.neuralModelTemperature)
        }
    }

    public func getNeuralModelResponseLength() -> Int? {
        getInt(.neuralModelResponseLength)
    }

    public func setNeuralModelResponseLength(value: Int?) {
        if let value {
            setValue(value, .neuralModelResponseLength)
        } else {
            removeValue(.neuralModelResponseLength)
        }
    }

    public func getSelectedTemplateIdByExaminationType() -> [String: String] {
        guard let data = defaults.data(forKey: DUserDefaultsKey.selectedTemplateIdByExaminationTypeMap.rawValue),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return decoded
    }

    public func setSelectedTemplateIdByExaminationType(value: [String: String]) {
        if value.isEmpty {
            removeValue(.selectedTemplateIdByExaminationTypeMap)
        } else if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: DUserDefaultsKey.selectedTemplateIdByExaminationTypeMap.rawValue)
        }
    }
}

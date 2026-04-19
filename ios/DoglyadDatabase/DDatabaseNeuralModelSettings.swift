import Foundation

// MARK: NeuralModelSettings -

public protocol DDatabaseNeuralModelSettingsProtocol: AnyObject {
    func getNeuralModelTemperature() -> Double?

    func setNeuralModelTemperature(value: Double?)

    func getNeuralModelResponseLength() -> Int?

    func setNeuralModelResponseLength(value: Int?)
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
}

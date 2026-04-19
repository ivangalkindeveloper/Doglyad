import Foundation

// MARK: USExaminationNeuralModel -

public protocol DDatabaseUSExaminationNeuralModelProtocol: AnyObject {
    func getSelectedUSExaminationNeuralModelId() -> String?
    
    func setSelectedUSExaminationNeuralModelId(value: String)
}

extension DDatabase: DDatabaseUSExaminationNeuralModelProtocol {
    public func getSelectedUSExaminationNeuralModelId() -> String? {
        getString(.selectedUSExaminationNeuralModelId)
    }

    public func setSelectedUSExaminationNeuralModelId(value: String) {
        setValue(value, .selectedUSExaminationNeuralModelId)
    }
}

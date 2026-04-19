import Foundation

public protocol DDatabaseUSExaminationTypeProtocol: AnyObject {
    func getSelectedUSExaminationTypeId() -> String?

    func setSelectedUSExaminationTypeId(value: String)
}

extension DDatabase: DDatabaseUSExaminationTypeProtocol {
    public func getSelectedUSExaminationTypeId() -> String? {
        getString(.selectedUSExaminationTypeId)
    }

    public func setSelectedUSExaminationTypeId(value: String) {
        setValue(value, .selectedUSExaminationTypeId)
    }
}

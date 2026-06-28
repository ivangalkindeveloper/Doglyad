import Foundation

public protocol DDatabaseClearProtocol: AnyObject {
    func clearAll() async
}

extension DDatabase: DDatabaseClearProtocol {
    public func clearAll() async {
        for key in DUserDefaultsKey.allCases {
            removeValue(key)
        }

        try? await examinationConclusions.clearAllExaminationConclusions()
        try? await examinationTemplates.clearAllExaminationTemplates()
    }
}

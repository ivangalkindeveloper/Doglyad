import Foundation

public protocol DDatabaseClearProtocol: AnyObject {
    func clearAll() async
}

extension DDatabase: DDatabaseClearProtocol {
    public func clearAll() async {
        for key in DUserDefaultsKey.allCases {
            removeValue(key)
        }

        await examinationConclusions.clearAllExaminationConclusions()
        await examinationTemplates.clearAllExaminationTemplates()
        await requestLimit.clearRequestLimit()
    }
}

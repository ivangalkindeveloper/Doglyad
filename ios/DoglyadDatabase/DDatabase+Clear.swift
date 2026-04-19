import Foundation

// MARK: Clear -

public protocol DDatabaseClearProtocol: AnyObject {
    @MainActor func clearAll()
}

extension DDatabase: DDatabaseClearProtocol {
    @MainActor public func clearAll() {
        for key in DUserDefaultsKey.allCases {
            removeValue(key)
        }

        clearAllExaminationConclusions()
        clearAllExaminationTemplates()
        clearRequestLimit()
    }
}

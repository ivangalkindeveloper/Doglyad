import Foundation

public protocol DDatabaseUserSettingsProtocol: AnyObject {
    func getUserEmail() -> String?

    func setUserEmail(value: String)
}

extension DDatabase: DDatabaseUserSettingsProtocol {
    public func getUserEmail() -> String? {
        getString(.userEmail)
    }

    public func setUserEmail(value: String) {
        setValue(value, .userEmail)
    }
}

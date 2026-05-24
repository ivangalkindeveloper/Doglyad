import Foundation

protocol UserSettingsRepositoryProtocol: AnyObject {
    func getUserEmail() -> String?

    func setUserEmail(_ email: String)
}

import Foundation

protocol UserSettingsRepositoryProtocol: AnyObject {
    func getUserEmail() -> String?

    func setUserEmail(_ email: String)

    func sendEmail(
        email: USExaminationEmail
    ) async throws
}

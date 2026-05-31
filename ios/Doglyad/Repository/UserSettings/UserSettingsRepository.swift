import DoglyadDatabase
import DoglyadNetwork

final class UserSettingsRepository: UserSettingsRepositoryProtocol {
    let database: DDatabaseProtocol
    let httpClient: DHttpClientProtocol

    init(
        database: DDatabaseProtocol,
        httpClient: DHttpClientProtocol
    ) {
        self.database = database
        self.httpClient = httpClient
    }
}

extension UserSettingsRepository {
    func getUserEmail() -> String? {
        database.getUserEmail()
    }

    func setUserEmail(_ email: String) {
        database.setUserEmail(value: email)
    }
}

extension UserSettingsRepository {
    static let sendEmailEndpoint: String = "/ultrasound_conclusion_send_email"

    func sendEmail(
        email: USExaminationEmail
    ) async throws {
        try await httpClient.post(
            endPoint: Self.sendEmailEndpoint,
            body: email,
            headers: nil,
            encoderUserInfo: nil
        )
    }
}

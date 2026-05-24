import DoglyadDatabase

final class UserSettingsRepository: UserSettingsRepositoryProtocol {
    let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
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

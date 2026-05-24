import Foundation

final class EnvironmentBase: EnvironmentProtocol {
    let type: EnvironmentType
    let baseUrl: URL
    let baseVersionPrefix: String = "/v1"
    let configUrl: URL

    init(
        type: EnvironmentType,
        baseUrl: URL
    ) {
        self.type = type
        self.baseUrl = baseUrl
        self.configUrl = URL(
            string: "https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master/backend/config/\(type.rawValue)/application.json"
        )!
    }
}

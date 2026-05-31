import Foundation

final class EnvironmentBase: EnvironmentProtocol {
    static let contentUrl: String = "https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master/backend/config/"

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
        configUrl = URL(string: "\(Self.contentUrl)\(type.rawValue)/application.json")!
    }
}

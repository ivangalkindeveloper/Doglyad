import Foundation

final class EnvironmentBase: EnvironmentProtocol {
    let type: EnvironmentType
    let baseUrl: URL
    let baseVersionPrefix: String = "/v1"
    let contentUrl: URL = .init(string: "https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master")!
    let contentConfigPathPrefix: String = "/backend/config"
    let updateUrl: URL = .init(string: "https://apps.apple.com/app/id")!
    let privacyPolicyUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/legal/privacy-policy")!
    let termsAndConditionsUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/legal/terms-and-conditions")!
    let contactEmail: String = "ivangalkindeveloper@gmail.com"

    init(
        type: EnvironmentType,
        baseUrl: URL
    ) {
        self.type = type
        self.baseUrl = baseUrl
    }
}

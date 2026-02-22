import Foundation

final class EnvironmentBase: EnvironmentProtocol {
    let baseUrl: URL
    let contentUrl: URL = .init(string: "https://raw.githubusercontent.com/ivangalkindeveloper/Doglyad/master/")!
    let updateUrl: URL = .init(string: "https://apps.apple.com/app/id")!
    let privacyPolicyUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/legal/privacy-policy/")!
    let termsAndConditionsUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/legal/terms-and-conditions/")!
    let contactEmail: String = "ivangalkindeveloper@gmail.com"

    init(
        baseUrl: URL
    ) {
        self.baseUrl = baseUrl
    }
}

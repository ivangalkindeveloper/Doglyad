import Foundation

final class EnvironmentBase: EnvironmentProtocol {
    let baseUrl: URL
    let privacyPolicyUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/privacy-policy/")!
    let termsAndConditionsUrl: URL = .init(string: "https://ivangalkindeveloper.github.io/Doglyad/terms-and-conditions/")!

    init(
        baseUrl: URL
    ) {
        self.baseUrl = baseUrl
    }
}

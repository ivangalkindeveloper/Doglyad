import Foundation

protocol EnvironmentProtocol: AnyObject {
    var type: EnvironmentType { get }
    var baseUrl: URL { get }
    var baseVersionPrefix: String { get }
    var contentUrl: URL { get }
    var updateUrl: URL { get }
    var privacyPolicyUrl: URL { get }
    var termsAndConditionsUrl: URL { get }
    var contactEmail: String { get }
}

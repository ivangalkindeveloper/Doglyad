import Foundation

protocol EnvironmentProtocol: AnyObject {
    var baseUrl: URL { get }
    var contentUrl: URL { get }
    var updateUrl: URL { get }
    var privacyPolicyUrl: URL { get }
    var termsAndConditionsUrl: URL { get }
    var contactEmail: String { get }
}

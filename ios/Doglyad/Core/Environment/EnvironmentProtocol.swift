import Foundation

protocol EnvironmentProtocol: AnyObject {
    var baseUrl: URL { get }
    var privacyPolicyUrl: URL { get }
    var termsAndConditionsUrl: URL { get }
}

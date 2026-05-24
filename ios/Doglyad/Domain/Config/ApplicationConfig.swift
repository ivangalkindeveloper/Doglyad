import Foundation

struct ApplicationConfig: Codable {
    let appStoreId: String
    let actualVersion: Version
    let contactEmail: String
    let configUrl: URL
    let appleUpdateUrl: URL
    let privacyPolicyUrl: URL
    let termsAndConditionsUrl: URL
    let ultrasound: UltrasoundConfig
}

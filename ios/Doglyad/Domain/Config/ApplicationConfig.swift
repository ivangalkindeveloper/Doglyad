import Foundation

struct ApplicationConfig: Codable {
    let appStoreId: String
    let actualVersion: Version
    let contactEmail: String
    let configUrl: URL
    let appleUpdateUrl: URL
    let privacyPolicyUrl: URL
    let termsAndConditionsUrl: URL
    let entitlements: [SubscriptionType: SubscriptionEntitlement]
    let ultrasound: UltrasoundConfig
}

extension ApplicationConfig {
    private enum CodingKeys: String, CodingKey {
        case appStoreId
        case actualVersion
        case contactEmail
        case configUrl
        case appleUpdateUrl
        case privacyPolicyUrl
        case termsAndConditionsUrl
        case entitlements
        case ultrasound
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appStoreId = try container.decode(String.self, forKey: .appStoreId)
        actualVersion = try container.decode(Version.self, forKey: .actualVersion)
        contactEmail = try container.decode(String.self, forKey: .contactEmail)
        configUrl = try container.decode(URL.self, forKey: .configUrl)
        appleUpdateUrl = try container.decode(URL.self, forKey: .appleUpdateUrl)
        privacyPolicyUrl = try container.decode(URL.self, forKey: .privacyPolicyUrl)
        termsAndConditionsUrl = try container.decode(URL.self, forKey: .termsAndConditionsUrl)
        ultrasound = try container.decode(UltrasoundConfig.self, forKey: .ultrasound)

        let rawEntitlements = try container.decode(
            [String: SubscriptionEntitlement].self,
            forKey: .entitlements
        )
        entitlements = Dictionary(
            uniqueKeysWithValues: rawEntitlements.compactMap { rawType, entitlement in
                SubscriptionType(rawValue: rawType).map { ($0, entitlement) }
            }
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appStoreId, forKey: .appStoreId)
        try container.encode(actualVersion, forKey: .actualVersion)
        try container.encode(contactEmail, forKey: .contactEmail)
        try container.encode(configUrl, forKey: .configUrl)
        try container.encode(appleUpdateUrl, forKey: .appleUpdateUrl)
        try container.encode(privacyPolicyUrl, forKey: .privacyPolicyUrl)
        try container.encode(termsAndConditionsUrl, forKey: .termsAndConditionsUrl)
        try container.encode(ultrasound, forKey: .ultrasound)

        let rawEntitlements = Dictionary(
            uniqueKeysWithValues: entitlements.map { type, entitlement in
                (type.rawValue, entitlement)
            }
        )
        try container.encode(rawEntitlements, forKey: .entitlements)
    }
}

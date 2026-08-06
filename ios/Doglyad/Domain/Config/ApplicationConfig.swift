import Foundation

struct ApplicationConfig: Codable {
    let appStoreId: String
    let actualVersion: Version
    let contactEmail: String
    let appleUpdateUrl: URL
    /// The revision date of the current legal documents. When it is newer than the
    /// one the user accepted, the re-acceptance screen is shown.
    let legalDate: Date
    let privacyPolicyUrl: URL
    let termsAndConditionsUrl: URL
    let network: NetworkConfig
    let entitlements: [SubscriptionType: SubscriptionEntitlement]
    let ultrasound: UltrasoundConfig
}

extension ApplicationConfig {
    private enum CodingKeys: String, CodingKey {
        case appStoreId
        case actualVersion
        case contactEmail
        case appleUpdateUrl
        case legalDate
        case privacyPolicyUrl
        case termsAndConditionsUrl
        case network
        case entitlements
        case ultrasound
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appStoreId = try container.decode(String.self, forKey: .appStoreId)
        actualVersion = try container.decode(Version.self, forKey: .actualVersion)
        contactEmail = try container.decode(String.self, forKey: .contactEmail)
        appleUpdateUrl = try container.decode(URL.self, forKey: .appleUpdateUrl)
        legalDate = try container.decodeIfPresent(Date.self, forKey: .legalDate) ?? .distantPast
        privacyPolicyUrl = try container.decode(URL.self, forKey: .privacyPolicyUrl)
        termsAndConditionsUrl = try container.decode(URL.self, forKey: .termsAndConditionsUrl)
        // Optional so a config published before this field existed still decodes; the
        // client then keeps its built-in timeouts instead of failing to start.
        network = try container.decodeIfPresent(NetworkConfig.self, forKey: .network) ?? .default
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
        try container.encode(appleUpdateUrl, forKey: .appleUpdateUrl)
        try container.encode(legalDate, forKey: .legalDate)
        try container.encode(privacyPolicyUrl, forKey: .privacyPolicyUrl)
        try container.encode(termsAndConditionsUrl, forKey: .termsAndConditionsUrl)
        try container.encode(network, forKey: .network)
        try container.encode(ultrasound, forKey: .ultrasound)

        let rawEntitlements = Dictionary(
            uniqueKeysWithValues: entitlements.map { type, entitlement in
                (type.rawValue, entitlement)
            }
        )
        try container.encode(rawEntitlements, forKey: .entitlements)
    }
}

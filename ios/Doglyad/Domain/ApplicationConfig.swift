struct ApplicationConfig: Codable {
    let appStoreId: String?
    let actualVersion: Version
}

extension ApplicationConfig {
    static let `default`: Self = .init(
        appStoreId: nil,
        actualVersion: .default
    )
}

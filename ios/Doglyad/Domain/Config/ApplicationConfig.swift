struct ApplicationConfig: Codable {
    let appStoreId: String
    let actualVersion: Version
    let contactEmail: String
    let ultrasound: UltrasoundConfig
}

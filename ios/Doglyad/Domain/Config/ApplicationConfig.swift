struct ApplicationConfig: Codable {
    let appStoreId: String
    let actualVersion: Version
    let ultrasound: UltrasoundConfig
}
struct UltrasoundConfig: Codable {
    let scanPhotoMaxNumber: Int
    let scanPhotoResizeMaxDimension: Int
    let scanPhotoCompressionQuality: Double
    let defaultPatientDateOfBirthGap: Int
    let defaultPatientHeightCM: Int
    let defaultPatientWeightKG: Int
}
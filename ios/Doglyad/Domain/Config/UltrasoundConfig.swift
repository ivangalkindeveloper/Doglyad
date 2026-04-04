struct UltrasoundConfig: Codable {
    let requestCountPerDay: Int
    let scanPhotoMaxNumber: Int
    let scanPhotoResizeMaxDimension: Double
    let scanPhotoCompressionQuality: Double
    let defaultPatientDateOfBirthGap: Int
    let defaultPatientHeightCM: Int
    let defaultPatientWeightKG: Int
}

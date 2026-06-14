struct UltrasoundConfig: Codable {
    let defaultNeuralModelTemperature: Double
    let defaultNeuralModelMaxTokens: Int
    let scanPhotoMaxNumber: Int
    let scanPhotoResizeMaxDimension: Double
    let scanPhotoCompressionQuality: Double
    let defaultPatientDateOfBirthGap: Int
    let defaultPatientHeightCM: Double
    let defaultPatientWeightKG: Double
}

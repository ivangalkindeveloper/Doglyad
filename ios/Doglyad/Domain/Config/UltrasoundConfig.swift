struct UltrasoundConfig: Codable {
    let defaultNeuralModelTemperature: Double
    let defalultNeuralModelResponseLength: Int
    let requestCountPerDay: Int
    let scanPhotoMaxNumber: Int
    let scanPhotoResizeMaxDimension: Double
    let scanPhotoCompressionQuality: Double
    let defaultPatientDateOfBirthGap: Int
    let defaultPatientHeightCM: Double
    let defaultPatientWeightKG: Double
}

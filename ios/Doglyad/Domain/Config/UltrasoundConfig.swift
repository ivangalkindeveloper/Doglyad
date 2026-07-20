import Foundation

struct UltrasoundConfig: Codable {
    let neuralModel: UltrasoundNeuralModelConfig
    let examinationNeuralModel: UltrasoundExaminationNeuralModelConfig
    let scanPhotoMaxNumber: Int
    let scanPhotoResizeMaxDimension: Double
    let scanPhotoCompressionQuality: Double
    let defaultPatientDateOfBirthGap: Int
    let defaultPatientHeightCM: Double
    let defaultPatientWeightKG: Double
}

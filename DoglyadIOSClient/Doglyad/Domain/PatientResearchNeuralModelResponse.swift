import Foundation

struct PatientResearchNeuralModelResponse: Codable {
    let patientName: String?
    let patientGender: PatientGender?
    let patientDateOfBirth: Date?
    let patientHeight: Double?
    let patientWeight: Double?
    let patientComplaint: String?
    let researchDescription: String?
    let additionalData: String?
}

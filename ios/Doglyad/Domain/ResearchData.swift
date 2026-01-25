import Foundation

struct ResearchData: Codable {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ResearchScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let patientDateOfBirth: Date
    let patientHeight: Double
    let patientWeight: Double
    let patientComplaint: String?
    let researchDescription: String
    let additionalData: String?
}

import Foundation

struct ResearchData {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ResearchScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let patientDateOfBirth: Date
    let scanDescription: String
    let patientComplaint: String?
    let additionalMedicalData: String?
}

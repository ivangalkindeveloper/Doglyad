import Foundation

struct ResearchData {
    let timestamp: Date
    let researchType: String
    let photos: [ScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let patientDateOfBirth: Date
    let scanData: String
    let patientComplaint: String?
    let additionalMedicalData: String?
}

import Foundation

struct ResearchConclusion {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let patientDateOfBirth: Date
    let scanData: String
    let patientComplaint: String?
    let additionalMedicalData: String?
    let modelConclusions: [ModelConclusion]
}

import Foundation

struct ResearchConclusion: Identifiable {
    let id = UUID()
    let date: Date
    let researchType: ResearchType
    let photos: [ResearchScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let patientDateOfBirth: Date
    let patientHeight: Double
    let patientWeight: Double
    let patientComplaint: String?
    let scanDescription: String
    let additionalMedicalData: String?
    let actualModelConclusion: ResearchModelConclusion
    let previosModelConclusions: [ResearchModelConclusion]
}

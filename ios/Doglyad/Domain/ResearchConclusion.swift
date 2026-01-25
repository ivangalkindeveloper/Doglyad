import Foundation

struct ResearchConclusion: Identifiable, Codable {
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
    let researchDescription: String
    let additionalData: String?
    let actualModelConclusion: ResearchModelConclusion
    let previosModelConclusions: [ResearchModelConclusion]
    
    private enum CodingKeys: String, CodingKey {
        case date,
             researchType,
             photos,
             patientName,
             patientGender,
             patientDateOfBirth,
             patientHeight,
             patientWeight,
             patientComplaint,
             researchDescription,
             additionalData,
             actualModelConclusion,
             previosModelConclusions
    }
}

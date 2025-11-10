import Foundation

struct ResearchData {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ScanPhoto]
    let patientName: String
    let patientGender: PatientGender
    let scanStrategyData: any ScanStrategyDataProtocol
    let patientComplaint: String
    let additionalMedicalData: String?
}

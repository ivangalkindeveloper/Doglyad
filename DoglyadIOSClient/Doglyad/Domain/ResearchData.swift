import Foundation

struct ResearchData {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ScanPhoto]
    let personalData: PatientPersonalData
    let anamnesis: PatientAnamnesis
}

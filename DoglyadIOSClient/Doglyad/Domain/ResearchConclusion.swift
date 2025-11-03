import Foundation

struct ResearchConclusion {
    let timestamp: Date
    let researchType: ResearchType
    let photos: [ScanPhoto]
    let personalData: PatientPersonalData
    let anamnesis: PatientAnamnesis
    let modelConclusions: [ModelConclusion]
}

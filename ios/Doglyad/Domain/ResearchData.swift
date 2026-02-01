import DoglyadDatabase
import Foundation

struct ResearchData: Codable {
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

extension ResearchData {
    static func fromDB(
        _ db: ResearchDataDB
    ) -> ResearchData {
        ResearchData(
            researchType: ResearchType.fromString(db.researchTypeRawValue) ?? .default,
            photos: db.photos.map { ResearchScanPhoto.fromDB($0) },
            patientName: db.patientName,
            patientGender: PatientGender(rawValue: db.patientGenderRawValue) ?? .male,
            patientDateOfBirth: db.patientDateOfBirth,
            patientHeight: db.patientHeight,
            patientWeight: db.patientWeight,
            patientComplaint: db.patientComplaint,
            researchDescription: db.researchDescription,
            additionalData: db.additionalData
        )
    }

    func toDB() -> ResearchDataDB {
        ResearchDataDB(
            researchTypeRawValue: researchType.rawValue,
            photos: photos.map { $0.toDB() },
            patientName: patientName,
            patientGenderRawValue: patientGender.rawValue,
            patientDateOfBirth: patientDateOfBirth,
            patientHeight: patientHeight,
            patientWeight: patientWeight,
            patientComplaint: patientComplaint,
            researchDescription: researchDescription,
            additionalData: additionalData
        )
    }
}

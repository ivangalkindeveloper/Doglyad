import Foundation
import SwiftData

@Model
public final class ResearchDataDB {
    public var researchTypeRawValue: String
    @Relationship public var photos: [ResearchScanPhotoDB]
    public var patientName: String
    public var patientGenderRawValue: String
    public var patientDateOfBirth: Date
    public var patientHeight: Double
    public var patientWeight: Double
    public var patientComplaint: String?
    public var researchDescription: String
    public var additionalData: String?

    public init(
        researchTypeRawValue: String,
        photos: [ResearchScanPhotoDB] = [],
        patientName: String,
        patientGenderRawValue: String,
        patientDateOfBirth: Date,
        patientHeight: Double,
        patientWeight: Double,
        patientComplaint: String?,
        researchDescription: String,
        additionalData: String?
    ) {
        self.researchTypeRawValue = researchTypeRawValue
        self.photos = photos
        self.patientName = patientName
        self.patientGenderRawValue = patientGenderRawValue
        self.patientDateOfBirth = patientDateOfBirth
        self.patientHeight = patientHeight
        self.patientWeight = patientWeight
        self.patientComplaint = patientComplaint
        self.researchDescription = researchDescription
        self.additionalData = additionalData
    }
}

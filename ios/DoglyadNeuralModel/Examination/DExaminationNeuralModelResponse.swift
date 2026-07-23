import Foundation

public struct DExaminationNeuralModelResponse: Codable {
    public enum Gender: String, Codable {
        case male
        case female

        @available(iOS 26.0, *)
        static func fromFoudationModels(
            _ response: DExaminationNeuralModelFoundationModels.Gender?
        ) -> Self? {
            switch response {
            case .male:
                return .male
            case .female:
                return .female
            case nil:
                return nil
            }
        }
    }

    public let patientName: String?
    public let patientGender: Gender?
    public let patientDateOfBirth: Date?
    public let patientHeightCM: Double?
    public let patientWeightKG: Double?
    public let patientComplaint: String?
    public let examinationDescription: String?

    /// Модель может выдать значение, не попадающее в схему: пол словом из диктовки,
    /// число строкой, дату в своём формате. Такое поле обнуляем, а не роняем весь разбор.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        patientName = try container.decodeIfPresent(String.self, forKey: .patientName)
        patientGender = try Gender(
            rawValue: container.decodeIfPresentLenientString(forKey: .patientGender)?.lowercased() ?? ""
        )
        patientDateOfBirth = try DExaminationGenerationConfig.dateFormatter.date(
            from: container.decodeIfPresentLenientString(forKey: .patientDateOfBirth) ?? ""
        )
        patientHeightCM = try container.decodeIfPresentLenientDouble(forKey: .patientHeightCM)
        patientWeightKG = try container.decodeIfPresentLenientDouble(forKey: .patientWeightKG)
        patientComplaint = try container.decodeIfPresent(String.self, forKey: .patientComplaint)
        examinationDescription = try container.decodeIfPresent(String.self, forKey: .examinationDescription)
    }

    init(
        patientName: String?,
        patientGender: Gender?,
        patientDateOfBirth: Date?,
        patientHeightCM: Double?,
        patientWeightKG: Double?,
        patientComplaint: String?,
        examinationDescription: String?
    ) {
        self.patientName = patientName
        self.patientGender = patientGender
        self.patientDateOfBirth = patientDateOfBirth
        self.patientHeightCM = patientHeightCM
        self.patientWeightKG = patientWeightKG
        self.patientComplaint = patientComplaint
        self.examinationDescription = examinationDescription
    }

    @available(iOS 26.0, *)
    static func fromFoudationModels(
        _ response: DExaminationNeuralModelFoundationModels.Response
    ) -> Self {
        DExaminationNeuralModelResponse(
            patientName: response.patientName,
            patientGender: Gender.fromFoudationModels(
                response.patientGender
            ),
            patientDateOfBirth: DExaminationGenerationConfig.dateFormatter.date(
                from: response.patientDateOfBirth ?? ""
            ),
            patientHeightCM: response.patientHeightCM,
            patientWeightKG: response.patientWeightKG,
            patientComplaint: response.patientComplaint,
            examinationDescription: response.examinationDescription
        )
    }
}

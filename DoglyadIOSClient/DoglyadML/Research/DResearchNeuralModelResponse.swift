import Foundation

public struct DResearchNeuralModelResponse: Decodable {
    
    public enum Gender: Decodable {
        case male
        case female
        
        @available(iOS 26.0, *)
        static func fromFoudationModels(
            _ response: DResearchNeuralModelFoundationModels.Gender?
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
    public let patientHeight: Double?
    public let patientWeight: Double?
    public let patientComplaint: String?
    public let researchDescription: String?
    public let additionalData: String?
    
    @available(iOS 26.0, *)
    static func fromFoudationModels(
        _ response: DResearchNeuralModelFoundationModels.Response
    ) -> Self {
        DResearchNeuralModelResponse(
            patientName: response.patientName,
            patientGender: Gender.fromFoudationModels(response.patientGender),
            patientDateOfBirth: DateFormatter().date(from: response.patientDateOfBirth ?? ""),
            patientHeight: response.patientHeight,
            patientWeight: response.patientWeight,
            patientComplaint: response.patientComplaint,
            researchDescription: response.researchDescription,
            additionalData: response.additionalData
        )
    }
    
}

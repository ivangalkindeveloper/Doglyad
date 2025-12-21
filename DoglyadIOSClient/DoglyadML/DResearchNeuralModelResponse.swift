import Foundation

public struct DResearchNeuralModelResponse {
    
    public enum Gender {
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

    let patientName: String?
    let patientGender: Gender?
    let patientDateOfBirth: Date?
    let patientHeight: Double?
    let patientWeight: Double?
    let patientComplaint: String?
    let researchDescription: String?
    let additionalData: String?
    
    @available(iOS 26.0, *)
    static func fromFoudationModels(
        _ response: DResearchNeuralModelFoundationModels.Response
    ) -> Self {
        DResearchNeuralModelResponse(
            patientName: response.patientName,
            patientGender: Gender.fromFoudationModels(response.patientGender),
            patientDateOfBirth: response.patientDateOfBirth,
            patientHeight: response.patientHeight,
            patientWeight: response.patientWeight,
            patientComplaint: response.patientComplaint,
            researchDescription: response.researchDescription,
            additionalData: response.additionalData
        )
    }
    
}

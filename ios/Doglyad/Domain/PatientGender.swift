import DoglyadNeuralModel

enum PatientGender: String, Codable {
    case male
    case female

    static func fromResearchNeuralModelResponse(
        _ response: DResearchNeuralModelResponse.Gender?
    ) -> Self? {
        switch response {
        case .male:
            return .male
        case .female:
            return .female
        case nil:
            return nil
        case .some:
            return nil
        }
    }
}

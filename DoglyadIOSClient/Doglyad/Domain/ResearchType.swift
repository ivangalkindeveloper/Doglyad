import Foundation

enum ResearchType: String {
    case thyroidGland // Щитовидная железа
    
    var components: [ResearchTypeComponentType] {
        switch self {
        case .thyroidGland:
            [
                .patientHeight,
                .patientWeight,
                .thyroidGlandIsthmus,
                .thyroidGlandRightLobe,
                .thyroidGlandLeftLobe
            ]
        }
    }
    
    static let `default`: ResearchType = .thyroidGland
    
    static func fromString(_ value: String?) -> ResearchType? {
        switch value {
        case ResearchType.thyroidGland.rawValue:
                .thyroidGland
        default:
            nil
        }
    }
}

extension ResearchType: Identifiable {
    var id: Self { self }
}

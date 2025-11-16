import Foundation

enum ResearchType: String {
    case thyroidGland // Щитовидная железа
    
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

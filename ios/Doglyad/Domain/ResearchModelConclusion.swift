import Foundation

struct ResearchModelConclusion: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let model: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case date,
             model,
             description
    }
}

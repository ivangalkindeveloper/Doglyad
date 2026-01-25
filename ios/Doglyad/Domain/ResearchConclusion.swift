import Foundation

struct ResearchConclusion: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let data: ResearchData
    let actualModelConclusion: ResearchModelConclusion
    let previosModelConclusions: [ResearchModelConclusion]
    
    private enum CodingKeys: String, CodingKey {
        case date,
             data,
             actualModelConclusion,
             previosModelConclusions
    }
}

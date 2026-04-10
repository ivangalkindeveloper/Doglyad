import Foundation

struct USExaminationTemplate: Codable, Identifiable, Equatable {
    let id: String
    let usExaminationType: USExaminationType
    let content: String
}

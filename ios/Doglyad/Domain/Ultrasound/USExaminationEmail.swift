import Foundation

struct USExaminationEmail: Encodable {
    let recipientEmail: String
    let examinationData: USExaminationData
    let modelConclusion: USExaminationModelConclusion
}

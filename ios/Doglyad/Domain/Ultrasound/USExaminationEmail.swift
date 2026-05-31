import Foundation

struct USExaminationEmail: Encodable {
    let recipientEmail: String
    let subject: String
    let body: String
}

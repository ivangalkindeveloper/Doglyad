import DoglyadDatabase
import Foundation

struct USExaminationTemplate: Codable, Identifiable, Equatable {
    var id: UUID = .init()
    let usExaminationType: USExaminationType
    let content: String
    
    init(
        id: UUID = UUID(),
        usExaminationType: USExaminationType,
        content: String
    ) {
        self.id = id
        self.usExaminationType = usExaminationType
        self.content = content
    }
}

extension USExaminationTemplate {
    static func fromDB(
        _ db: USExaminationTemplateDB,
        usExaminationType: USExaminationType
    ) -> USExaminationTemplate {
        USExaminationTemplate(
            id: db.id,
            usExaminationType: usExaminationType,
            content: db.content
        )
    }

    func toDB() -> USExaminationTemplateDB {
        USExaminationTemplateDB(
            id: id,
            usExaminationTypeId: usExaminationType.id,
            content: content
        )
    }
}

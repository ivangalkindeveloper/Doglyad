import DoglyadDatabase
import Foundation

final class TemplateRepository: TemplateRepositoryProtocol {
    private let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }

    @MainActor func getTemplates(
        usExaminationTypesById: [String: USExaminationType]
    ) -> [USExaminationTemplate] {
        database.getExaminationTemplates().compactMap { db in
            guard let type = usExaminationTypesById[db.usExaminationTypeId] else { return nil }
            return USExaminationTemplate(
                id: db.id,
                usExaminationType: type,
                content: db.content
            )
        }
    }

    @MainActor func getTemplate(
        id: String,
        usExaminationTypesById: [String: USExaminationType]
    ) -> USExaminationTemplate? {
        getTemplates(usExaminationTypesById: usExaminationTypesById).first { $0.id == id }
    }

    @MainActor func saveTemplate(_ template: USExaminationTemplate) {
        database.upsertExaminationTemplate(
            value: USExaminationTemplateDB(
                id: template.id,
                usExaminationTypeId: template.usExaminationType.id,
                content: template.content
            )
        )
    }

    @MainActor func deleteTemplate(id: String) {
        database.deleteExaminationTemplate(id: id)
        var map = database.getSelectedTemplateIdByExaminationType()
        for (examinationTypeId, templateId) in map where templateId == id {
            map.removeValue(forKey: examinationTypeId)
        }
        database.setSelectedTemplateIdByExaminationType(value: map)
    }

    func getSelectedTemplateIdByExaminationType() -> [String: String] {
        database.getSelectedTemplateIdByExaminationType()
    }

    func setSelectedTemplateId(_ templateId: String?, forExaminationTypeId: String) {
        var map = database.getSelectedTemplateIdByExaminationType()
        if let templateId {
            map[forExaminationTypeId] = templateId
        } else {
            map.removeValue(forKey: forExaminationTypeId)
        }
        database.setSelectedTemplateIdByExaminationType(value: map)
    }
}

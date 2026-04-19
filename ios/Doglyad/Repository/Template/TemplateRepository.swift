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
            return USExaminationTemplate.fromDB(db, usExaminationType: type)
        }
    }

    @MainActor func getTemplate(
        id: UUID,
        usExaminationTypesById: [String: USExaminationType]
    ) -> USExaminationTemplate? {
        getTemplates(usExaminationTypesById: usExaminationTypesById).first { $0.id == id }
    }

    @MainActor func saveTemplate(
        template: USExaminationTemplate
    ) {
        database.upsertExaminationTemplate(value: template.toDB())
    }

    @MainActor func deleteTemplate(
        id: UUID
    ) {
        database.deleteExaminationTemplate(id: id)
        var map = database.getSelectedTemplateIdByExaminationType()
        for (examinationTypeId, templateId) in map where templateId == id {
            map.removeValue(forKey: examinationTypeId)
        }
        database.setSelectedTemplateIdByExaminationType(value: map)
    }

    func getTemplateIdByUSExaminationType() -> [String: UUID] {
        database.getSelectedTemplateIdByExaminationType()
    }

    func setTemplateIdByUSExaminaionType(
        templateId: UUID?,
        USExaminationTypeId: String
    ) {
        var map = database.getSelectedTemplateIdByExaminationType()
        if let templateId {
            map[USExaminationTypeId] = templateId
        } else {
            map.removeValue(forKey: USExaminationTypeId)
        }
        database.setSelectedTemplateIdByExaminationType(value: map)
    }
}

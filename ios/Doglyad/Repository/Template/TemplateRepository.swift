import DoglyadDatabase
import Foundation

final class TemplateRepository: TemplateRepositoryProtocol {
    private let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }

    func getTemplates(
        usExaminationTypesById: [String: USExaminationType]
    ) async -> [USExaminationTemplate] {
        await database.examinationTemplates.fetchExaminationTemplates { dbs in
            dbs.compactMap { db in
                guard let type = usExaminationTypesById[db.usExaminationTypeId] else { return nil }
                return USExaminationTemplate.fromDB(db, usExaminationType: type)
            }
        }
    }

    func getTemplatesByUSExaminationId(
        usExaminationTypesById: [String: USExaminationType]
    ) async -> [String: USExaminationTemplate] {
        await database.examinationTemplates.fetchExaminationTemplates { dbs in
            var map: [String: USExaminationTemplate] = [:]
            for db in dbs {
                guard let type = usExaminationTypesById[db.usExaminationTypeId] else { continue }
                let template = USExaminationTemplate.fromDB(db, usExaminationType: type)
                map[type.id] = template
            }
            return map
        }
    }

    func getTemplate(
        id: UUID,
        usExaminationTypesById: [String: USExaminationType]
    ) async -> USExaminationTemplate? {
        let templates = await getTemplates(usExaminationTypesById: usExaminationTypesById)
        return templates.first { $0.id == id }
    }

    func saveTemplate(
        template: USExaminationTemplate
    ) async {
        await database.examinationTemplates.upsertExaminationTemplate(value: template.toDB())
    }

    func deleteTemplate(
        id: UUID
    ) async {
        await database.examinationTemplates.deleteExaminationTemplate(id: id)
    }
}

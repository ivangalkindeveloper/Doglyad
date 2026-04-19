import Foundation

protocol TemplateRepositoryProtocol: AnyObject {
    func getTemplates(
        usExaminationTypesById: [String: USExaminationType]
    ) async -> [USExaminationTemplate]

    func getTemplatesByUSExaminationId(
        usExaminationTypesById: [String: USExaminationType]
    ) async -> [String: USExaminationTemplate]

    func getTemplate(
        id: UUID,
        usExaminationTypesById: [String: USExaminationType]
    ) async -> USExaminationTemplate?

    func saveTemplate(template: USExaminationTemplate) async

    func deleteTemplate(id: UUID) async
}

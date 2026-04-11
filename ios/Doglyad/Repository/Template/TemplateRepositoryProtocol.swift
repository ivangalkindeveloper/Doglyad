import Foundation

protocol TemplateRepositoryProtocol: AnyObject {
    @MainActor func getTemplates(
        usExaminationTypesById: [String: USExaminationType]
    ) -> [USExaminationTemplate]

    @MainActor func getTemplate(
        id: UUID,
        usExaminationTypesById: [String: USExaminationType]
    ) -> USExaminationTemplate?

    @MainActor func saveTemplate(template: USExaminationTemplate)

    @MainActor func deleteTemplate(id: UUID)

    @MainActor func getSelectedTemplateIdByExaminationType() -> [String: String]

    @MainActor func setSelectedTemplateId(id: UUID?, forExaminationTypeId: String)
}

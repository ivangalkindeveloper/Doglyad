import Foundation

protocol TemplateRepositoryProtocol: AnyObject {
    @MainActor func getTemplates(
        usExaminationTypesById: [String: USExaminationType]
    ) -> [USExaminationTemplate]

    @MainActor func getTemplate(
        id: String,
        usExaminationTypesById: [String: USExaminationType]
    ) -> USExaminationTemplate?

    @MainActor func saveTemplate(_ template: USExaminationTemplate)

    @MainActor func deleteTemplate(id: String)

    @MainActor func getSelectedTemplateIdByExaminationType() -> [String: String]

    @MainActor func setSelectedTemplateId(_ templateId: String?, forExaminationTypeId: String)
}

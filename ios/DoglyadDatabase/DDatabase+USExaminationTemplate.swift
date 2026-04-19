import Foundation
import SwiftData

// MARK: USExaminationTemplate -

public protocol DDatabaseUSExaminationTemplateProtocol: AnyObject {
    @MainActor func getExaminationTemplates() -> [USExaminationTemplateDB]

    @MainActor func upsertExaminationTemplate(value: USExaminationTemplateDB)

    @MainActor func deleteExaminationTemplate(id: UUID)
    
    @MainActor func clearAllExaminationTemplates()
}

extension DDatabase: DDatabaseUSExaminationTemplateProtocol {
    @MainActor public func getExaminationTemplates() -> [USExaminationTemplateDB] {
        let descriptor = FetchDescriptor<USExaminationTemplateDB>(
            sortBy: [SortDescriptor(\.usExaminationTypeId, order: .forward)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor public func upsertExaminationTemplate(
        value: USExaminationTemplateDB
    ) {
        let id = value.id
        let descriptor = FetchDescriptor<USExaminationTemplateDB>(
            predicate: #Predicate<USExaminationTemplateDB> { $0.id == id }
        )
        if let existing = try? container.mainContext.fetch(descriptor).first {
            existing.usExaminationTypeId = value.usExaminationTypeId
            existing.content = value.content
        } else {
            container.mainContext.insert(value)
        }
    }

    @MainActor public func deleteExaminationTemplate(id: UUID) {
        let descriptor = FetchDescriptor<USExaminationTemplateDB>(
            predicate: #Predicate<USExaminationTemplateDB> { $0.id == id }
        )
        guard let item = try? container.mainContext.fetch(descriptor).first else { return }
        container.mainContext.delete(item)
    }

    @MainActor public func clearAllExaminationTemplates() {
        for item in getExaminationTemplates() {
            container.mainContext.delete(item)
        }
    }
}

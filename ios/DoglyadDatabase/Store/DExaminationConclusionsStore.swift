import Foundation
import SwiftData

@ModelActor
public actor DExaminationConclusionsStore {
    public func fetchExaminationConclusions<T: Sendable>(
        _ transform: @Sendable ([USExaminationConclusionDB]) -> T
    ) -> T {
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return transform(models)
    }

    public func setExaminationConclusion(value: USExaminationConclusionDB) throws {
        modelContext.insert(value)
        try modelContext.save()
    }

    public func updateExaminationConclusion(value: USExaminationConclusionDB) throws {
        let id = value.id
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            predicate: #Predicate<USExaminationConclusionDB> { $0.id == id }
        )
        guard let conclusion = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(conclusion)
        modelContext.insert(value)
        try modelContext.save()
    }

    public func clearAllExaminationConclusions() throws {
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        let conclusions = (try? modelContext.fetch(descriptor)) ?? []
        for conclusion in conclusions {
            modelContext.delete(conclusion)
        }
        try modelContext.save()
    }
}

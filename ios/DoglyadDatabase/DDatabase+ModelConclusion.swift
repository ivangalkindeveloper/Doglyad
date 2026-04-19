import Foundation
import SwiftData

// MARK: ModelConclusion -

public protocol DDatabaseModelConclusionProtocol: AnyObject {
    @MainActor func getExaminationConclusions() -> [USExaminationConclusionDB]

    @MainActor func setExaminationConclusion(value: USExaminationConclusionDB)

    @MainActor func updateExaminationConclusion(value: USExaminationConclusionDB)
    
    @MainActor func clearAllExaminationConclusions()
}

extension DDatabase: DDatabaseModelConclusionProtocol {
    @MainActor public func getExaminationConclusions() -> [USExaminationConclusionDB] {
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor public func setExaminationConclusion(
        value: USExaminationConclusionDB
    ) {
        container.mainContext.insert(value)
    }

    @MainActor public func updateExaminationConclusion(
        value: USExaminationConclusionDB
    ) {
        let id = value.id
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            predicate: #Predicate<USExaminationConclusionDB> { $0.id == id }
        )
        guard let conclusion = try? container.mainContext.fetch(descriptor).first else { return }

        container.mainContext.delete(conclusion)
        setExaminationConclusion(value: value)
    }

    @MainActor public func clearAllExaminationConclusions() {
        let conclusions = getExaminationConclusions()
        for conclusion in conclusions {
            container.mainContext.delete(conclusion)
        }
    }
}

import Foundation
import SwiftData

public final class DDatabase: DDatabaseProtocol {
    private let defaults: UserDefaults = .standard
    private var container: ModelContainer

    public init() throws {
        let schema = Schema([
            NeuralModelSettingsDB.self,
            USExaminationConclusionDB.self,
            USExaminationDataDB.self,
            USExaminationScanPhotoDB.self,
            USExaminationModelConclusionDB.self,
            RequestLimitDB.self,
            USExaminationTemplateDB.self,
        ])
        container = try ModelContainer(
            for: schema
        )
    }
}

private extension DDatabase {
    func getBool(_ key: DUserDefaultsKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    func getString(_ key: DUserDefaultsKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    func getInt(_ key: DUserDefaultsKey) -> Int? {
        defaults.object(forKey: key.rawValue) as? Int
    }

    func setValue<T>(_ value: T, _ key: DUserDefaultsKey) -> Void {
        defaults.set(value, forKey: key.rawValue)
    }

    func removeValue(_ key: DUserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}

// MARK: OnBoarding -

public extension DDatabase {
    func getOnBoardingCompleted() -> Bool {
        getBool(.isOnBoardingCompleted)
    }

    func setOnBoardingCompleted(value: Bool) {
        setValue(value, .isOnBoardingCompleted)
    }
}

// MARK: NeuralModelSettings -

public extension DDatabase {
    func getNeuralModelResponseTemplate() -> String? {
        getString(.neuralModelResponseTemplate)
    }

    func setNeuralModelResponseTemplate(value: String?) {
        if let value {
            setValue(value, .neuralModelResponseTemplate)
        } else {
            removeValue(.neuralModelResponseTemplate)
        }
    }

    func getNeuralModelResponseLength() -> Int? {
        getInt(.neuralModelResponseLength)
    }

    func setNeuralModelResponseLength(value: Int?) {
        if let value {
            setValue(value, .neuralModelResponseLength)
        } else {
            removeValue(.neuralModelResponseLength)
        }
    }

    func getSelectedTemplateIdByExaminationType() -> [String: String] {
        guard let data = defaults.data(forKey: DUserDefaultsKey.selectedTemplateIdByExaminationTypeMap.rawValue),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return decoded
    }

    func setSelectedTemplateIdByExaminationType(value: [String: String]) {
        if value.isEmpty {
            removeValue(.selectedTemplateIdByExaminationTypeMap)
        } else if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: DUserDefaultsKey.selectedTemplateIdByExaminationTypeMap.rawValue)
        }
    }
}

// MARK: USExaminationType -

public extension DDatabase {
    func getSelectedUSExaminationTypeId() -> String? {
        getString(.selectedUSExaminationTypeId)
    }

    func setSelectedUSExaminationTypeId(value: String) {
        setValue(value, .selectedUSExaminationTypeId)
    }
}

// MARK: USExaminationNeuralModel -

public extension DDatabase {
    func getSelectedUSExaminationNeuralModelId() -> String? {
        getString(.selectedUSExaminationNeuralModelId)
    }

    func setSelectedUSExaminationNeuralModelId(value: String) {
        setValue(value, .selectedUSExaminationNeuralModelId)
    }
}

// MARK: USExaminationTemplate -

public extension DDatabase {
    @MainActor func getExaminationTemplates() -> [USExaminationTemplateDB] {
        let descriptor = FetchDescriptor<USExaminationTemplateDB>(
            sortBy: [SortDescriptor(\.usExaminationTypeId, order: .forward)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor func upsertExaminationTemplate(
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

    @MainActor func deleteExaminationTemplate(id: String) {
        let descriptor = FetchDescriptor<USExaminationTemplateDB>(
            predicate: #Predicate<USExaminationTemplateDB> { $0.id == id }
        )
        guard let item = try? container.mainContext.fetch(descriptor).first else { return }
        container.mainContext.delete(item)
    }

    @MainActor func clearAllExaminationTemplates() {
        for item in getExaminationTemplates() {
            container.mainContext.delete(item)
        }
    }
}

// MARK: ModelConclusion -

public extension DDatabase {
    @MainActor func getExaminationConclusions() -> [USExaminationConclusionDB] {
        let descriptor = FetchDescriptor<USExaminationConclusionDB>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor func setExaminationConclusion(
        value: USExaminationConclusionDB
    ) {
        container.mainContext.insert(value)
    }

    @MainActor func updateExaminationConclusion(
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

    @MainActor func clearAllExaminationConclusions() {
        let conclusions = getExaminationConclusions()
        for conclusion in conclusions {
            container.mainContext.delete(conclusion)
        }
    }
}

// MARK: RequestLimit -

public extension DDatabase {
    @MainActor func getRequestLimit() -> RequestLimitDB? {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor func setRequestLimit(value: RequestLimitDB) {
        clearRequestLimit()
        container.mainContext.insert(value)
    }

    @MainActor func clearRequestLimit() {
        let descriptor = FetchDescriptor<RequestLimitDB>()
        guard let items = try? container.mainContext.fetch(descriptor) else { return }
        for item in items {
            container.mainContext.delete(item)
        }
    }
}

// MARK: Clear -

public extension DDatabase {
    @MainActor func clearAll() {
        for key in DUserDefaultsKey.allCases {
            removeValue(key)
        }

        clearAllExaminationConclusions()
        clearAllExaminationTemplates()
        clearRequestLimit()
    }
}

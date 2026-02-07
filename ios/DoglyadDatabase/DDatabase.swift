import Foundation
import SwiftData

public final class DDatabase: DDatabaseProtocol {
    private let defaults: UserDefaults = .standard
    private var container: ModelContainer

    public init() throws {
        let schema = Schema([
            ResearchConclusionDB.self,
            ResearchDataDB.self,
            ResearchScanPhotoDB.self,
            ResearchModelConclusionDB.self,
            NeuralModelSettingsDB.self,
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

    func setting<T>(_ value: T, _ key: DUserDefaultsKey) -> Void {
        defaults.set(value, forKey: key.rawValue)
    }

    func removeValue(_ key: DUserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    func getInt(_ key: DUserDefaultsKey) -> Int? {
        defaults.object(forKey: key.rawValue) as? Int
    }
}

// MARK: OnBoarding -

public extension DDatabase {
    func getOnBoardingCompleted() -> Bool {
        getBool(.isOnBoardingCompleted)
    }

    func setOnBoardingCompleted(value: Bool) {
        setting(value, .isOnBoardingCompleted)
    }
}

// MARK: NeuralModelSettings -

public extension DDatabase {
    func getNeuralModelTemplate() -> String? {
        getString(.neuralModelTemplate)
    }

    func setNeuralModelTemplate(value: String?) {
        if let value {
            setting(value, .neuralModelTemplate)
        } else {
            removeValue(.neuralModelTemplate)
        }
    }

    func getNeuralModelResponseLength() -> Int? {
        getInt(.neuralModelResponseLength)
    }

    func setNeuralModelResponseLength(value: Int?) {
        if let value {
            setting(value, .neuralModelResponseLength)
        } else {
            removeValue(.neuralModelResponseLength)
        }
    }
}

// MARK: ResearchType -

public extension DDatabase {
    func getSelectedUSResearchType() -> String? {
        getString(.selectedUSResearchType)
    }

    func setSelectedUSResearchType(value: String) {
        setting(value, .selectedUSResearchType)
    }
}

// MARK: ModelConclusion -

public extension DDatabase {
    @MainActor func getResearchConclusions() -> [ResearchConclusionDB] {
        let descriptor = FetchDescriptor<ResearchConclusionDB>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor func setResearchConclusion(
        value: ResearchConclusionDB
    ) {
        container.mainContext.insert(value)
    }

    @MainActor func updateResearchConclusion(
        value: ResearchConclusionDB
    ) {
        let id = value.id
        let descriptor = FetchDescriptor<ResearchConclusionDB>(
            predicate: #Predicate<ResearchConclusionDB> { $0.id == id }
        )
        guard let conclusion = try? container.mainContext.fetch(descriptor).first else { return }

        container.mainContext.delete(conclusion)
        setResearchConclusion(value: value)
    }
}

import Foundation
import SwiftData

public protocol DDatabaseProtocol: AnyObject {
    func getOnBoardingCompleted() -> Bool
    
    func setOnBoardingCompleted(value: Bool) -> Void
    
    func getSelectedUSResearchType() -> String?
    
    func setSelectedUSResearchType(value: String) -> Void
}

public final class DDatabase: DDatabaseProtocol {
    private var container: ModelContainer
    private let defaults: UserDefaults = UserDefaults.standard
    
    public init() throws {
        let schema = Schema([
            // Model
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        self.container = try ModelContainer(
            for: schema,
            configurations: [
                modelConfiguration
            ])
    }
    
    private func getBool(_ key: DUserDefaultsKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    private func getString(_ key: DUserDefaultsKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    private func setting<T>(_ value: T, _ key: DUserDefaultsKey) -> Void {
        defaults.set(value, forKey: key.rawValue)
    }
}

public extension DDatabase {
    func getOnBoardingCompleted() -> Bool {
        getBool(.isOnBoardingCompleted)
    }
    
    func setOnBoardingCompleted(value: Bool) -> Void {
        setting(value, .isOnBoardingCompleted)
    }
    
    func getSelectedUSResearchType() -> String? {
        getString(.selectedUSRecearchType)
    }
    
    func setSelectedUSResearchType(value: String) -> Void {
        setting(value, .selectedUSRecearchType)
    }
}

import DoglyadDB

protocol DiagnosticsRepositoryProtocol {
    // MARK: OnBoarding
    func isOnBoardingCompleted() -> Bool
    
    func setOnBoardingCompleted(value: Bool) -> Void
    
    // MARK: ResearchType
    func getSelectedResearchType() -> ResearchType?
    
    func setSelectedResearchType(type: ResearchType) -> Void
}

final class DiagnosticsRepository: DiagnosticsRepositoryProtocol {
    let database: DDatabaseProtocol
    
    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }
}

// MARK: OnBoarding
extension DiagnosticsRepository {
    func isOnBoardingCompleted() -> Bool {
        database.getOnBoardingCompleted()
    }
    
    func setOnBoardingCompleted(value: Bool) -> Void {
        database.setOnBoardingCompleted(value: value)
    }
}

// MARK: ResearchType
extension DiagnosticsRepository {
    func getSelectedResearchType() -> ResearchType? {
        ResearchType.fromString(database.getSelectedUSResearchType())
    }
    
    func setSelectedResearchType(type: ResearchType) -> Void {
        database.setSelectedUSResearchType(value: type.rawValue)
    }
}

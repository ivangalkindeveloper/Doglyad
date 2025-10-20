//
//  DiagnosticsRepository.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import DoglyadDB

protocol DiagnosticsRepositoryProtocol {
    // MARK: OnBoarding
    func isOnBoardingCompleted() -> Bool
    
    func setOnBoardingCompleted(value: Bool) -> Void
    
    // MARK: ResearchType
    func getSelectedUSResearchType() -> USResearchType?
    
    func setSelectedUSResearchType(type: USResearchType) -> Void
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
    func getSelectedUSResearchType() -> USResearchType? {
        USResearchType.fromString(database.getSelectedUSResearchType())
    }
    
    func setSelectedUSResearchType(type: USResearchType) -> Void {
        database.setSelectedUSResearchType(value: type.rawValue)
    }
}

import DoglyadDatabase

protocol SharedRepositoryProtocol {
    func isOnBoardingCompleted() -> Bool
    
    func setOnBoardingCompleted(value: Bool) -> Void
}

final class SharedRepository: SharedRepositoryProtocol {
    let database: DDatabaseProtocol
    
    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }
}

// MARK: OnBoarding -
extension SharedRepository {
    func isOnBoardingCompleted() -> Bool {
        database.getOnBoardingCompleted()
    }
    
    func setOnBoardingCompleted(value: Bool) -> Void {
        database.setOnBoardingCompleted(
            value: value
        )
    }
}

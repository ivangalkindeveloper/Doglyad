protocol SharedRepositoryProtocol: AnyObject {
    func isOnBoardingCompleted() -> Bool

    func setOnBoardingCompleted(value: Bool)
}

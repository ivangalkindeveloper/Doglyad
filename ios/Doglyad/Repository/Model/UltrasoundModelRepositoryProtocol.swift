protocol UltrasoundModelRepositoryProtocol: AnyObject {
    // MARK: Model -

    func getSelectedModelId() -> String?

    func setSelectedModelId(id: String)

    func getIsMarkdown() -> Bool

    func setIsMarkdown(_ value: Bool)

    func getTemperature() -> Double?

    func setTemperature(_ value: Double?)

    func getResponseLength() -> Int?

    func setResponseLength(_ value: Int?)

    // MARK: RequestLimit -

    func remainingRequestCount(
        limit: Int
    ) async -> Int

    func incrementRequestCount() async
}

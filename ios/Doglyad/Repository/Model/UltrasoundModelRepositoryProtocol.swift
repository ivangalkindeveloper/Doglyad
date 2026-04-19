protocol UltrasoundModelRepositoryProtocol: AnyObject {
    // MARK: Model -

    func getSelectedModelId() -> String?

    func setSelectedModelId(id: String)

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

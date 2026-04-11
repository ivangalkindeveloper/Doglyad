protocol UltrasoundModelRepositoryProtocol: AnyObject {
    // MARK: Model -

    func getSelectedModelId() -> String?

    func setSelectedModelId(id: String)

    func getTemperature() -> Double?

    func setTemperature(_ value: Double?)

    func getResponseLength() -> Int?

    func setResponseLength(_ value: Int?)

    // MARK: RequestLimit -

    @MainActor func remainingRequestCount(
        limit: Int
    ) -> Int

    @MainActor func incrementRequestCount()
}

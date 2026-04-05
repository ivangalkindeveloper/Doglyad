protocol UltrasoundModelRepositoryProtocol: AnyObject {
    // MARK: Model -

    func getSelectedModelId() -> String?

    func setSelectedModelId(
        id: String
    )

    // MARK: Settings -

    func getSettings() -> NeuralModelSettings

    func setSettings(settings: NeuralModelSettings)

    // MARK: RequestLimit -

    @MainActor func remainingRequestCount(
        limit: Int
    ) -> Int

    @MainActor func incrementRequestCount()
}

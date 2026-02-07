protocol ModelRepositoryProtocol: AnyObject {
    // MARK: NeuralModelSettings -

    func getNeuralModelSettings() -> NeuralModelSettings

    func setNeuralModelSettings(settings: NeuralModelSettings)
}

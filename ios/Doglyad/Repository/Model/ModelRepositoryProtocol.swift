protocol ModelRepositoryProtocol: AnyObject {
    // MARK: USExaminationNeuralModel -

    func getSelectedUSExaminationNeuralModelId() -> String?

    func setSelectedUSExaminationNeuralModelId(
        id: String
    )

    // MARK: NeuralModelSettings -

    func getNeuralModelSettings() -> NeuralModelSettings

    func setNeuralModelSettings(settings: NeuralModelSettings)
}

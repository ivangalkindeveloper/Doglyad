enum InitializationError: Error {
    case noInternetConnection
    case noCameraRequestDenied
    case serviceUnavailable(email: String)
    case usExaminationTypesEmpty
    case usExaminationNeuralModelsEmpty
    case examinationNeuralModelPromptEmpty
    case common
}

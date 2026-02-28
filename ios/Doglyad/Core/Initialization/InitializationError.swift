enum InitializationError: Error {
    case noInternetConnection
    case noCameraRequestDenied
    case usExaminationTypesEmpty
    case usExaminationNeuralModelsEmpty
    case common
}

import DoglyadDatabase
import Foundation

final class UltrasoundModelRepository: UltrasoundModelRepositoryProtocol {
    let database: DDatabaseProtocol

    init(
        database: DDatabaseProtocol
    ) {
        self.database = database
    }
}

// MARK: Model -

extension UltrasoundModelRepository {
    func getSelectedModelId() -> String? {
        database.getSelectedUSExaminationNeuralModelId()
    }

    func setSelectedModelId(
        id: String
    ) {
        database.setSelectedUSExaminationNeuralModelId(
            value: id
        )
    }

    func getResponseLength() -> Int? {
        database.getNeuralModelResponseLength()
    }

    func setResponseLength(_ value: Int?) {
        database.setNeuralModelResponseLength(value: value)
    }

    func getTemperature() -> Double? {
        database.getNeuralModelTemperature()
    }

    func setTemperature(_ value: Double?) {
        database.setNeuralModelTemperature(value: value)
    }
}

// MARK: RequestLimit -

extension UltrasoundModelRepository {
    func remainingRequestCount(
        limit: Int
    ) async -> Int {
        await database.requestLimit.fetchRequestLimit { requestLimit in
            guard let requestLimit,
                  Calendar.current.isDateInToday(requestLimit.date)
            else { return limit }
            return max(limit - requestLimit.count, 0)
        }
    }

    func incrementRequestCount() async {
        await database.requestLimit.incrementRequestCount()
    }
}

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
    @MainActor func remainingRequestCount(
        limit: Int
    ) -> Int {
        guard let requestLimit = database.getRequestLimit(),
              Calendar.current.isDateInToday(requestLimit.date)
        else { return limit }
        return max(limit - requestLimit.count, 0)
    }

    @MainActor func incrementRequestCount() {
        if let requestLimit = database.getRequestLimit(),
           Calendar.current.isDateInToday(requestLimit.date)
        {
            requestLimit.count += 1
        } else {
            database.setRequestLimit(value: RequestLimitDB(count: 1, date: Date()))
        }
    }
}

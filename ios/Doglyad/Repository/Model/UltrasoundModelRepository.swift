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
}

// MARK: Settings -

extension UltrasoundModelRepository {
    func getSettings() -> NeuralModelSettings {
        NeuralModelSettings(
            selectedNeuralModelId: database.getSelectedUSExaminationNeuralModelId(),
            template: database.getNeuralModelResponseTemplate(),
            responseLength: database.getNeuralModelResponseLength()
        )
    }

    func setSettings(settings: NeuralModelSettings) {
        if let selectedNeuralModelId = settings.selectedNeuralModelId {
            database.setSelectedUSExaminationNeuralModelId(value: selectedNeuralModelId)
        }
        database.setNeuralModelResponseTemplate(value: settings.template)
        database.setNeuralModelResponseLength(value: settings.responseLength)
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

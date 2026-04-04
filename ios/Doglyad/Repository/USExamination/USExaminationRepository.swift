import DoglyadDatabase
import DoglyadNetwork
import Foundation

final class USExaminationRepository: USExaminationRepositoryProtocol {
    let database: DDatabaseProtocol
    let httpClient: DHttpClientProtocol

    init(
        database: DDatabaseProtocol,
        httpClient: DHttpClientProtocol
    ) {
        self.database = database
        self.httpClient = httpClient
    }
}

// MARK: USExaminationType -

extension USExaminationRepository {
    func getSelectedUSExaminationTypeId() -> String? {
        database.getSelectedUSExaminationTypeId()
    }

    func setSelectedUSExaminationTypeId(
        id: String
    ) {
        database.setSelectedUSExaminationTypeId(
            value: id
        )
    }
}

// MARK: Conclusion -

extension USExaminationRepository {
    static var conclusionEndpoint: String = "/ultrasound_conclusion"

    func generateConclusion(
        locale: Locale,
        request: USExaminationRequest,
        scanPhotoEncodingOptions: ScanPhotoEncodingOptions
    ) async throws -> USExaminationModelConclusion {
        try await httpClient.post(
            endPoint: USExaminationRepository.conclusionEndpoint,
            body: request,
            headers: [
                DHttpHeader.acceptLanguage: locale.identifier,
            ],
            encoderUserInfo: [
                .scanPhotoEncodingOptions: scanPhotoEncodingOptions,
            ]
        )
    }

    @MainActor func getConclusions() -> [USExaminationConclusion] {
        database.getExaminationConclusions().map { USExaminationConclusion.fromDB($0) }
    }

    @MainActor func setConclusion(
        conclusion: USExaminationConclusion
    ) {
        database.setExaminationConclusion(value: conclusion.toDB())
    }

    @MainActor func updateConclusion(
        conclusion: USExaminationConclusion
    ) {
        database.updateExaminationConclusion(value: conclusion.toDB())
    }

    @MainActor func clearAllConclusions() {
        database.clearAllExaminationConclusions()
    }
}

// MARK: RequestLimit -

extension USExaminationRepository {
    @MainActor func isRequestLimitReached(limit: Int) -> Bool {
        guard let requestLimit = database.getRequestLimit() else { return false }
        guard Calendar.current.isDateInToday(requestLimit.date) else { return false }
        return requestLimit.count >= limit
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

// MARK: Common -

extension USExaminationRepository {
    @MainActor func clearAll() {
        database.clearAll()
    }
}

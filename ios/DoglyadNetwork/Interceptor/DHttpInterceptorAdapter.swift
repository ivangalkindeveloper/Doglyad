import Foundation
internal import Alamofire

/// Мост между независимым от Alamofire протоколом `DHttpInterceptorProtocol` и
/// `RequestInterceptor` Alamofire. Оборачивает async-`adapt` в completion-API.
struct DHttpInterceptorAdapter: RequestInterceptor {
    private let interceptor: DHttpInterceptorProtocol

    init(interceptor: DHttpInterceptorProtocol) {
        self.interceptor = interceptor
    }

    func adapt(
        _ urlRequest: URLRequest,
        for _: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        Task {
            do {
                let adapted = try await interceptor.adapt(urlRequest)
                completion(.success(adapted))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

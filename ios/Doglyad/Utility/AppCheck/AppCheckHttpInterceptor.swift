import DoglyadNetwork
import FirebaseAppCheck
import Foundation

/// Добавляет к каждому исходящему запросу заголовок с Firebase App Check токеном,
/// подтверждающим, что запрос идёт из подлинного приложения (под капотом App Attest).
/// Токен затем проверяется на бэкенде.
struct AppCheckHttpInterceptor: DHttpInterceptorProtocol {
    func adapt(
        _ urlRequest: URLRequest
    ) async throws -> URLRequest {
        let token = try await AppCheck.appCheck().token(forcingRefresh: false)
        var request = urlRequest
        request.setValue(
            token.token,
            forHTTPHeaderField: DHttpHeader.firebaseAppCheck
        )
        return request
    }
}

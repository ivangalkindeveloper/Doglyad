public import Foundation

/// Перехватчик исходящих запросов. Реализация может модифицировать `URLRequest`
/// перед отправкой (например, добавить заголовок с токеном). Реализуется во
/// внешнем модуле и передаётся в `DHttpClient` через init — так сетевой слой не
/// зависит от источника токена (Firebase и т.п.).
public protocol DHttpInterceptorProtocol: Sendable {
    func adapt(
        _ urlRequest: URLRequest
    ) async throws -> URLRequest
}

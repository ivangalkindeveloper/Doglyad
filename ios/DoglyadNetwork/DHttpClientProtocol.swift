public protocol DHttpClientProtocol {
    var baseUrl: String { get }
    
    func get<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body?,
        headers: [String: String]?
    ) async throws -> Response

    func post<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body?,
        headers: [String: String]?
    ) async throws -> Response
}

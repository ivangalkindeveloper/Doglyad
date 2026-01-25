public protocol DHttpClientProtocol {
    var baseUrl: String { get }
    
    func get<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body?
    ) async throws -> Response
}

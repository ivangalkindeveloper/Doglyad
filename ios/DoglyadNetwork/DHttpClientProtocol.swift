public import Foundation

public protocol DHttpClientProtocol {
    var baseUrl: String { get }

    func get<Response: Decodable>(
        url: URL
    ) async throws -> Response
    
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

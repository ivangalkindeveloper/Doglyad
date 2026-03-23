public import Foundation
internal import Alamofire

public final class DHttpClient: DHttpClientProtocol {
    public let baseUrl: String
    public let baseVersionPrefix: String

    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 300
        return Session(configuration: configuration)
    }()

    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private var baseApiUrl: String {
        baseUrl + baseVersionPrefix
    }

    public init(
        baseUrl: String,
        baseVersionPrefix: String
    ) {
        self.baseUrl = baseUrl
        self.baseVersionPrefix = baseVersionPrefix
    }

    public func get<Response: Decodable>(
        url: URL
    ) async throws -> Response {
        let response = await session.request(
            url,
            method: .get
        )
        .validate()
        .serializingDecodable(Response.self, decoder: jsonDecoder)
        .response
        return try response.result.get()
    }

    public func get<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body? = nil,
        headers: [String: String]? = nil
    ) async throws -> Response {
        let response = await session.request(
            baseApiUrl + endPoint,
            method: .get,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: jsonEncoder),
            headers: headers.map(HTTPHeaders.init) ?? HTTPHeaders()
        )
        .validate()
        .serializingDecodable(Response.self, decoder: jsonDecoder)
        .response
        return try response.result.get()
    }

    public func post<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body? = nil,
        headers: [String: String]? = nil
    ) async throws -> Response {
        let response = await session.request(
            baseApiUrl + endPoint,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: jsonEncoder),
            headers: headers.map(HTTPHeaders.init) ?? HTTPHeaders()
        )
        .validate()
        .serializingDecodable(Response.self, decoder: jsonDecoder)
        .response
        return try response.result.get()
    }
}

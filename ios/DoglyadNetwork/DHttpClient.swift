private import Alamofire

public final class DHttpClient: DHttpClientProtocol {
    public let baseUrl: String

    public init(
        baseUrl: String
    ) {
        self.baseUrl = baseUrl
    }

    public func get<Body: Encodable & Sendable, Response: Decodable>(
        endPoint: String,
        body: Body? = nil
    ) async throws -> Response {
        await AF.request(
            baseUrl + endPoint,
            method: .get,
            parameters: body
        )
        .validate()
        .serializingDecodable(Response.self)
        .response
        .value!
    }
}

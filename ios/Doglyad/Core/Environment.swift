import Foundation

protocol EnvironmentProtocol: AnyObject {
    var baseURL: URL { get }
}

final class EnvironmentBase: EnvironmentProtocol {
    let baseURL: URL

    init(
        baseURL: URL
    ) {
        self.baseURL = baseURL
    }
}

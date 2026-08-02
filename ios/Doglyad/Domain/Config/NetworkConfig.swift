import Foundation

/// Timeouts applied to the shared HTTP client. Kept in the remote config so they can be
/// tuned without a release — inference requests wait on a serverless worker that may need
/// a cold start.
struct NetworkConfig: Codable {
    /// How long to wait for the *next* chunk of data. The timer resets whenever new bytes
    /// arrive, so it fires only when the connection stalls, not on a slow-but-alive transfer.
    let timeoutIntervalForRequest: TimeInterval
    /// The deadline for the whole request, counted from its start regardless of activity.
    let timeoutIntervalForResource: TimeInterval
}

extension NetworkConfig {
    /// Used until the remote config arrives, and when it carries no `network` section.
    static let `default` = NetworkConfig(
        timeoutIntervalForRequest: 300,
        timeoutIntervalForResource: 300
    )
}

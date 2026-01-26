import Foundation

public struct DMessage: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let body: String
}

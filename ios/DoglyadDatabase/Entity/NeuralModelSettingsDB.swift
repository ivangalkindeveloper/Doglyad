import Foundation
import SwiftData

@Model
public final class NeuralModelSettingsDB {
    public var template: String?
    public var responseLength: Int?

    public init(
        template: String?,
        responseLength: Int?
    ) {
        self.template = template
        self.responseLength = responseLength
    }
}

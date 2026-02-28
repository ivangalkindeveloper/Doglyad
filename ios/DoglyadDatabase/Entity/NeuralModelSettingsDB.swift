import Foundation
import SwiftData

@Model
public final class NeuralModelSettingsDB {
    public var selectedNeuralModelId: String?
    public var template: String?
    public var responseLength: Int?

    public init(
        selectedNeuralModelId: String?,
        template: String?,
        responseLength: Int?
    ) {
        self.selectedNeuralModelId = selectedNeuralModelId
        self.template = template
        self.responseLength = responseLength
    }
}

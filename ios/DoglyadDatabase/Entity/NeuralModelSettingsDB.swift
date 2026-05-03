import Foundation
import SwiftData

@Model
public final class NeuralModelSettingsDB {
    public var selectedNeuralModelId: String?
    public var isMarkdown: Bool
    public var temperature: Double?
    public var responseLength: Int?

    public init(
        selectedNeuralModelId: String?,
        isMarkdown: Bool = false,
        temperature: Double?,
        responseLength: Int?
    ) {
        self.selectedNeuralModelId = selectedNeuralModelId
        self.isMarkdown = isMarkdown
        self.temperature = temperature
        self.responseLength = responseLength
    }
}

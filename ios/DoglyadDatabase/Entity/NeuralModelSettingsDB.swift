import Foundation
import SwiftData

@Model
public final class NeuralModelSettingsDB {
    public var selectedNeuralModelId: String?
    public var temperature: Double?
    public var responseLength: Int?

    public init(
        selectedNeuralModelId: String?,
        temperature: Double?,
        responseLength: Int?
    ) {
        self.selectedNeuralModelId = selectedNeuralModelId
        self.temperature = temperature
        self.responseLength = responseLength
    }
}

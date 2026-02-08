import DoglyadNeuralModel
import Router

final class ScanSpeechBottomSheetArguments: RouteArgumentsProtocol {
    let onComplete: ((DResearchNeuralModelResponse) -> Void)?

    init(
        onComplete: ((DResearchNeuralModelResponse) -> Void)?
    ) {
        self.onComplete = onComplete
    }
}

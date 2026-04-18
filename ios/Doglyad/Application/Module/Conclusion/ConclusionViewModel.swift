import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import SwiftUI
import UIKit

@MainActor
@Observable
final class ConclusionViewModel: Handler<DHttpApiError, DHttpConnectionError> {
    static let actualModelConclusionCardScrollId = "actualModelConclusionCard"

    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        initialConclusion: USExaminationConclusion
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        conclusion = initialConclusion
    }

    var conclusion: USExaminationConclusion
    var isLoading = false

    func onTapBack() {
        router.pop()
    }

    var conclusionShareContent: String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(conclusion),
              let string = String(data: data, encoding: .utf8)
        else { return "" }
        return string
    }

    func onTapCopy(
        conclusion: USExaminationModelConclusion
    ) {
        UIPasteboard.general.string = conclusion.response
        messager.show(
            type: .success,
            title: .conclusionModelResponseCopyMessageTitle,
            description: .conclusionModelResponseCopyMessageDescription
        )
    }

    func onTapRepeatScan(
        proxy: ScrollViewProxy
    ) {
        let ultrasoundModelRepository = container.ultrasoundModelRepository
        let neuralModelSettings = NeuralModelSettings(
            selectedNeuralModelId: ultrasoundModelRepository.getSelectedModelId(),
            temperature: ultrasoundModelRepository.getTemperature(),
            responseLength: ultrasoundModelRepository.getResponseLength()
        )
        let request = USExaminationRequest(
            neuralModelSettings: neuralModelSettings,
            examinationData: conclusion.examinationData
        )

        handle {
            self.isLoading = true
            let ultrasoundConfig = self.container.applicationConfig.ultrasound
            return try await self.container.ultrasoundConclusionRepository.generateConclusion(
                locale: Locale.current,
                request: request,
                scanPhotoEncodingOptions: ScanPhotoEncodingOptions(
                    resizeMaxDimension: ultrasoundConfig.scanPhotoResizeMaxDimension,
                    compressionQuality: ultrasoundConfig.scanPhotoCompressionQuality
                )
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { modelConclusion in
            let updatedConclusion = USExaminationConclusion(
                id: self.conclusion.id,
                date: self.conclusion.date,
                neuralModelSettings: neuralModelSettings,
                examinationData: self.conclusion.examinationData,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: [self.conclusion.actualModelConclusion] + self.conclusion.previosModelConclusions
            )

            self.container.ultrasoundConclusionRepository.updateConclusion(
                conclusion: updatedConclusion
            )

            self.conclusion = updatedConclusion
            withAnimation {
                proxy.scrollTo(Self.actualModelConclusionCardScrollId, anchor: .top)
            }
            self.messager.show(
                type: .success,
                title: .conclusionModelResponseUpdatedMessageTitle,
                description: .conclusionModelResponseUpdatedMessageDescription
            )
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }
}

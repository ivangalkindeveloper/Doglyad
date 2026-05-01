import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: BaseViewModel {
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

    @Published var conclusion: USExaminationConclusion
    @Published var isLoading = false

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
        handle {
            self.isLoading = true
            let requestTemplate: String? = await {
                let typeId = self.conclusion.examinationData.usExaminationTypeId
                if let template = await self.container.templateRepository.getTemplatesByUSExaminationId(usExaminationTypesById: self.container.usExaminationTypesById)[typeId] {
                    return await self.container.templateRepository.getTemplate(
                        id: template.id,
                        usExaminationTypesById: self.container.usExaminationTypesById
                    )?.content
                }
                return nil
            }()
            let request = USExaminationRequest(
                neuralModelSettings: neuralModelSettings,
                examinationData: self.conclusion.examinationData,
                template: requestTemplate
            )
            let ultrasoundConfig = self.container.applicationConfig.ultrasound
            let modelConclusion = try await self.container.ultrasoundConclusionRepository.generateConclusion(
                locale: Locale.current,
                request: request,
                scanPhotoEncodingOptions: ScanPhotoEncodingOptions(
                    resizeMaxDimension: ultrasoundConfig.scanPhotoResizeMaxDimension,
                    compressionQuality: ultrasoundConfig.scanPhotoCompressionQuality
                )
            )
            let updatedConclusion = USExaminationConclusion(
                id: self.conclusion.id,
                date: self.conclusion.date,
                neuralModelSettings: neuralModelSettings,
                examinationData: self.conclusion.examinationData,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: [self.conclusion.actualModelConclusion] + self.conclusion.previosModelConclusions
            )
            await self.container.ultrasoundConclusionRepository.updateConclusion(
                conclusion: updatedConclusion
            )

            return updatedConclusion
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { updatedConclusion in
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

import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import Router
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: DViewModel {
    static let actualModelConclusionCardScrollId = "actualModelConclusionCard"

    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let getNeuralModelSettings: () -> NeuralModelSettings
    private let refreshSubscriptionStatus: () async -> Void
    private let getIsActive: () -> Bool
    private let onIncrementRequestCount: () -> Void

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        initialConclusion: USExaminationConclusion,
        refreshSubscriptionStatus: @escaping () async -> Void,
        getIsActive: @escaping () -> Bool,
        getNeuralModelSettings: @escaping () -> NeuralModelSettings,
        onIncrementRequestCount: @escaping () -> Void
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.refreshSubscriptionStatus = refreshSubscriptionStatus
        self.getIsActive = getIsActive
        self.getNeuralModelSettings = getNeuralModelSettings
        self.onIncrementRequestCount = onIncrementRequestCount
        conclusion = initialConclusion
    }

    @Published var conclusion: USExaminationConclusion
    @Published var isLoading = false

    func onTapBack() {
        router.pop()
    }

    func onTapShare() {
        router.push(
            route: RouteSheet(
                type: .share,
                arguments: ShareArguments(
                    conclusion: conclusion
                )
            )
        )
    }

    func onTapCopy(
        conclusion: USExaminationModelConclusion
    ) {
        UIApplication.pasteboard(conclusion.response)
        messager.show(
            type: .success,
            title: .conclusionModelCopyMessageTitle,
            description: .conclusionModelCopyMessageDescription
        )
    }

    func onTapNeuralModelSettings() {
        router.push(
            route: RouteScreen(
                type: .neuralModel
            )
        )
    }

    func onTapRepeatScan(
        proxy: ScrollViewProxy
    ) {
        handle {
            await self.refreshSubscriptionStatus()
        } onMainSuccess: { _ in
            guard self.getIsActive() else {
                return self.router.push(
                    route: RouteScreen(
                        type: .subscriptionPaywall
                    )
                )
            }
            self.performRepeatScan(proxy: proxy)
        }
    }

    private func performRepeatScan(
        proxy: ScrollViewProxy
    ) {
        handle {
            self.isLoading = true

            let neuralModelSettings = getNeuralModelSettings()
            let template: String? = await {
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
                template: template
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
            self.onIncrementRequestCount()

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

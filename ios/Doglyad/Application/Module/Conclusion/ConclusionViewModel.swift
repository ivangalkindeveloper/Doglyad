import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import NestedObservableObject
import Router
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: DViewModel {
    static let actualModelConclusionCardScrollId = "actualModelConclusionCard"

    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let getNeuralModel: () -> USExaminationNeuralModel
    private let onNeuralModelSelected: (USExaminationNeuralModel) -> Void
    @NestedObservableObject private var subscription: SubscriptionViewModel

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        initialConclusion: USExaminationConclusion,
        subscription: SubscriptionViewModel,
        getNeuralModel: @escaping () -> USExaminationNeuralModel,
        onNeuralModelSelected: @escaping (USExaminationNeuralModel) -> Void
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        _subscription = NestedObservableObject(wrappedValue: subscription)
        self.getNeuralModel = getNeuralModel
        self.onNeuralModelSelected = onNeuralModelSelected
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

    func onTapNeuralModelSelection() {
        router.push(
            route: RouteSheet(
                type: .selectNeuralModel,
                arguments: SelectNeuralModelArguments(
                    currentValue: getNeuralModel(),
                    onSelected: { [weak self] model in
                        self?.onNeuralModelSelected(model)
                    }
                )
            )
        )
    }

    func onTapNeuralModelSettings() {
        subscription.run(.neuralModelSettings, router: router) {
            self.router.push(
                route: RouteScreen(
                    type: .neuralModelSettings
                )
            )
        }
    }

    func onTapRepeatScan(
        proxy: ScrollViewProxy
    ) {
        handle {
            await self.subscription.refreshStatus()
        } onMainSuccess: { _ in
            guard self.subscription.isActive else {
                return self.router.push(
                    route: RouteScreen(
                        type: .subscriptionPaywall
                    )
                )
            }
            guard self.subscription.availableRequestCount > 0 else {
                return self.router.push(
                    route: RouteSheet(
                        type: .requestLimitExceeded,
                        arguments: RequestLimitExceededArguments()
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

            let neuralModelSettings = self.subscription.neuralModelSettings
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
            self.subscription.incrementRequestCount()

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

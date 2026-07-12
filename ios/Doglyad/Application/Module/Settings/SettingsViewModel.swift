import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
final class SettingsViewModel: DViewModel {
    private let container: DependencyContainer
    private let router: DRouter
    private let getIsActive: () -> Bool
    private let getNeuralModelSettingsAvailability: () -> SubscriptionFeatureAvailability
    private let getSendingConclusionByEmailAvailability: () -> SubscriptionFeatureAvailability
    private let onNeuralModelSelected: (USExaminationNeuralModel) -> Void

    init(
        container: DependencyContainer,
        router: DRouter,
        initialNeuralModel: USExaminationNeuralModel,
        getIsActive: @escaping () -> Bool,
        getNeuralModelSettingsAvailability: @escaping () -> SubscriptionFeatureAvailability,
        getSendingConclusionByEmailAvailability: @escaping () -> SubscriptionFeatureAvailability,
        onNeuralModelSelected: @escaping (USExaminationNeuralModel) -> Void
    ) {
        self.container = container
        self.router = router
        self.getIsActive = getIsActive
        self.getNeuralModelSettingsAvailability = getNeuralModelSettingsAvailability
        self.getSendingConclusionByEmailAvailability = getSendingConclusionByEmailAvailability
        self.onNeuralModelSelected = onNeuralModelSelected
        neuralModel = initialNeuralModel
        super.init()
    }

    @Published var conclusions: [USExaminationConclusion] = []
    @Published var neuralModel: USExaminationNeuralModel

    override func onInit() {
        handle {
            await self.container.ultrasoundConclusionRepository.getConclusions()
        } onMainSuccess: { conclusions in
            self.conclusions = conclusions
        }
    }

    func onTapBack() {
        router.pop()
    }

    func historyDescription() -> LocalizedStringResource {
        conclusions.isEmpty ? .settingsHistoryEmptyDescription : .settingsHistoryDescription(count: conclusions.count)
    }

    func onTapHistory() {
        router.push(
            route: RouteScreen(
                type: .history
            )
        )
    }

    func onTapTemplates() {
        router.push(
            route: RouteScreen(
                type: .templateList
            )
        )
    }

    func onTapUserSettings() {
        router.push(
            route: RouteScreen(
                type: .userSettings
            )
        )
    }

    func onTapSubscription() {
        router.push(
            route: RouteScreen(
                type: .subscription
            )
        )
    }

    func onTapNeuralModelSelection() {
        router.push(
            route: RouteSheet(
                type: .selectNeuralModel,
                arguments: SelectNeuralModelArguments(
                    currentValue: neuralModel,
                    onSelected: { [weak self] model in
                        guard let self = self else { return }
                        guard self.neuralModel != model else { return }

                        self.neuralModel = model
                        self.onNeuralModelSelected(model)
                    }
                )
            )
        )
    }

    var isNeuralModelSettingsVisible: Bool {
        switch getNeuralModelSettingsAvailability() {
        case .offered, .available:
            return true
        case .unavailable:
            return false
        }
    }

    var isNeuralModelSettingsProBadgeVisible: Bool {
        switch getNeuralModelSettingsAvailability() {
        case .offered:
            return true
        case .available, .unavailable:
            return false
        }
    }

    func onTapNeuralModelSettings() {
        switch getNeuralModelSettingsAvailability() {
        case .available:
            break
        case .offered:
            return router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
        case .unavailable:
            return
        }

        router.push(
            route: RouteScreen(
                type: .neuralModelSettings
            )
        )
    }

    func onTapStorage() {
        router.push(
            route: RouteScreen(
                type: .storage
            )
        )
    }

    func onTapPrivacyPolicy() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: container.applicationConfig.privacyPolicyUrl,
                    title: .privacyPolicyTitle
                )
            )
        )
    }

    func onTapTermsAndConditions() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: container.applicationConfig.termsAndConditionsUrl,
                    title: .termsAndConditionsTitle
                )
            )
        )
    }

    func onTapAboutApp() {
        router.push(
            route: RouteSheet(
                type: .about
            )
        )
    }
}

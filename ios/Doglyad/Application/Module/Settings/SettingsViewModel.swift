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

    init(
        container: DependencyContainer,
        router: DRouter,
        getIsActive: @escaping () -> Bool
    ) {
        self.container = container
        self.router = router
        self.getIsActive = getIsActive
        super.init()
    }

    @Published var conclusions: [USExaminationConclusion] = []

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

    func onTapNeuralModel() {
        router.push(
            route: RouteScreen(
                type: .neuralModel
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

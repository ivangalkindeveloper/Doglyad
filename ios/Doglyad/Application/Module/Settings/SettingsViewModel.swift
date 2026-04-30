import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel: BaseViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
        super.init()
    }

    var conclusions: [USExaminationConclusion] = []

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
                    url: container.environment.privacyPolicyUrl,
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
                    url: container.environment.termsAndConditionsUrl,
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

import Foundation
import Router
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private let environment: EnvironmentProtocol
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter

    init(
        environment: EnvironmentProtocol,
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.environment = environment
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        load()
    }

    @Published var conclusions: [ResearchConclusion] = []

    private func load() {
        let conclusions = diagnosticRepository.getConclusions()
        self.conclusions = conclusions
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

    func onTapNeuralModel() {
        router.push(
            route: RouteScreen(
                type: .neuralModel
            )
        )
    }

    func onTapPrivacyPolicy() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: environment.privacyPolicyUrl,
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
                    url: environment.termsAndConditionsUrl,
                    title: .termsAndConditionsTitle
                )
            )
        )
    }

    func onTapAboutApp() {}
}

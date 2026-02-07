import Foundation
import Router
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter

    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        self.load()
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
        self.conclusions.isEmpty ? .settingsHistoryEmptyDescription : .settingsHistoryDescription(count: self.conclusions.count)
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

    func onTapTermsAndConditions() {}

    func onTapAboutApp() {}
}

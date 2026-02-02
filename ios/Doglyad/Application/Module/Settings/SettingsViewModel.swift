import Foundation
import Router
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private let router: DRouter

    init(
        router: DRouter
    ) {
        self.router = router
    }

    func onTapBack() {
        router.pop()
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

    func onTapTerms() {}

    func onTapAboutApp() {}
}

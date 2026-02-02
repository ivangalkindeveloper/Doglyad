import Foundation
import Router
import SwiftUI

@MainActor
final class NeuralModelViewModel: ObservableObject {
    private let router: DRouter

    init(
        router: DRouter
    ) {
        self.router = router
    }

    func onTapBack() {
        router.pop()
    }
}

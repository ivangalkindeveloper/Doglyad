import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class NewVersionViewModel {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container
    }

    func onTapUpdate() {
        let id = container.applicationConfig.appStoreId
        UIApplication.openAppStore(
            environment: container.environment,
            id: id
        )
    }
}

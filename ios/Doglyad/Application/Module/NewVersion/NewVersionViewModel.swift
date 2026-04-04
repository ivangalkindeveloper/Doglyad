import Foundation
import UIKit

@MainActor
final class NewVersionViewModel: ObservableObject {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container
    }

    func onTapUpdate() {
        guard let id = container.applicationConfig.appStoreId else { return }
        UIApplication.openAppStore(
            environment: container.environment,
            id: id
        )
    }
}

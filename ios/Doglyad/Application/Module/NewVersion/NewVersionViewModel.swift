import Foundation
import UIKit

@MainActor
final class NewVersionViewModel: ObservableObject {
    private let environment: EnvironmentProtocol
    private let applicationConfig: ApplicationConfig

    init(
        environment: EnvironmentProtocol,
        applicationConfig: ApplicationConfig
    ) {
        self.environment = environment
        self.applicationConfig = applicationConfig
    }

    func onTapUpdate() {
        guard let id = applicationConfig.appStoreId else { return }
        UIApplication.openAppStore(
            environment: environment,
            id: id
        )
    }
}

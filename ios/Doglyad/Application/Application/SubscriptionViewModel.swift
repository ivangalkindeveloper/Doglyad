import Foundation
import Handler

@MainActor
final class SubscriptionViewModel: DViewModel {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container
        status = container.initialSubscriptionStatus
        super.init()
    }

    @Published var status: SubscriptionStatus?

    var isActive: Bool {
        status != nil
    }

    var availableRequestCount: Int {
        status?.availableCountPerDay ?? 0
    }

    func refreshStatus() async {
        handle {
            try await self.container.subscriptionRepository.fetchStatus(
                configEntitlements: self.container.applicationConfig.entitlements
            )
        } onMainSuccess: { status in
            self.status = status
        }
    }

    func incrementRequestCount() {
        handle {
            try await self.container.subscriptionRepository.incrementRequestCount(
                configEntitlements: self.container.applicationConfig.entitlements
            )
        } onMainSuccess: { status in
            self.status = status
        }
    }
}

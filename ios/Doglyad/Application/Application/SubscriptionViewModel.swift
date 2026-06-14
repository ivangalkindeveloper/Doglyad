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
        availableRequestCount = container.initialRemainingRequestCount
        super.init()
    }

    @Published var status: SubscriptionStatus?
    @Published var availableRequestCount: Int

    var isActive: Bool {
        status?.isActive == true
    }

    func refreshStatus() async {
        handle {
            try await self.container.subscriptionRepository.fetchStatus(
                configEntitlements: self.container.applicationConfig.entitlements
            )
        } onMainSuccess: { status in
            self.status = status
            self.refreshRemainingRequestCount()
        }
    }

    private func refreshRemainingRequestCount() {
        guard let limit = status?.requestCountPerDay else { return }
        handle {
            await self.container.ultrasoundModelRepository.remainingRequestCount(
                limit: limit
            )
        } onMainSuccess: { count in
            self.availableRequestCount = count
        }
    }

    func incrementRequestCount() {
        guard let limit = status?.requestCountPerDay else { return }
        handle {
            await self.container.ultrasoundModelRepository.incrementRequestCount()
            return await self.container.ultrasoundModelRepository.remainingRequestCount(
                limit: limit
            )
        } onMainSuccess: { count in
            self.availableRequestCount = count
        }
    }
}

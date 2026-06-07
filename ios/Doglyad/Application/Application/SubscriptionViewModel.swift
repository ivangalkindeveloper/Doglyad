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
            ?? container.subscriptionRepository.cachedStatus()
        availableRequestCount = container.applicationConfig.ultrasound.requestCountPerDay
        super.init()
    }

    @Published var status: SubscriptionStatus?
    @Published var availableRequestCount: Int

    var isActive: Bool {
        status?.isActive == true
    }

    override func onInit() {
        handle {
            await self.container.ultrasoundModelRepository.remainingRequestCount(
                limit: self.container.applicationConfig.ultrasound.requestCountPerDay
            )
        } onMainSuccess: { count in
            self.availableRequestCount = count
        }
    }

    func refreshStatus() async {
        handle {
            try await self.container.subscriptionRepository.fetchStatus()
        } onMainSuccess: { status in
            self.status = status
        }
    }

    func incrementRequestCount() {
        let limit = container.applicationConfig.ultrasound.requestCountPerDay
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

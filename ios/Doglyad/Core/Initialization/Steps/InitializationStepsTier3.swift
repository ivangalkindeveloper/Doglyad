import DependencyInitializer
import DoglyadNetwork
import Foundation

extension InitializationProcess {
    /// A set of its own on purpose: async steps within one `StepSet` run concurrently, so
    /// applying the config has to sit between the tier that loads it and the tiers that
    /// issue requests with the client.
    static let stepsTier3 = StepSet(
        sync: [
            SyncInitializationStep<InitializationProcess>(
                title: "Network configuration",
                run: { (process: InitializationProcess) in
                    let network = process.applicationConfig!.network
                    process.httpClient!.updateConfiguration(
                        timeoutIntervalForRequest: network.timeoutIntervalForRequest,
                        timeoutIntervalForResource: network.timeoutIntervalForResource
                    )
                }
            ),
        ]
    )
}

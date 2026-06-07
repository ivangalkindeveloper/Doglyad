import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let stepsTier2 = StepSet(
        async: [
            AsyncInitializationStep<InitializationProcess>(
                title: "Permission",
                run: { (process: InitializationProcess) in
                    let isGranted = await process.permissionManager!.isGranted(.camera)
                    if !isGranted {
                        throw InitializationError.noCameraRequestDenied
                    }
                }
            ),
        ]
    )
}

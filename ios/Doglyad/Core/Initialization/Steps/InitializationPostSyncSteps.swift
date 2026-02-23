import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let postSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Research types",
            run: { (process: InitializationProcess) -> Void in
                process.researchTypes = ResearchType.allCases
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Initial screen",
            run: { (process: InitializationProcess) -> Void in
                if Bundle.shortVersion.major < process.applicationConfig!.actualVersion.major && process.applicationConfig?.appStoreId != nil {
                    return process.initialScreen = .newVersion
                }
                
                let isOnBoardingCompleted = process.database!.getOnBoardingCompleted()
                let selectedUSResearchType = process.database!.getSelectedUSResearchType()
                if isOnBoardingCompleted, selectedUSResearchType != nil {
                    return process.initialScreen = .scan
                }
                process.initialScreen = .onBoarding
            }
        ),
    ]
}

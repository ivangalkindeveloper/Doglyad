import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let postSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Initial screen",
            run: { (process: InitializationProcess) in
                if Bundle.shortVersion.major < process.applicationConfig!.actualVersion.major, process.applicationConfig?.appStoreId != nil {
                    return process.initialScreen = .newVersion
                }

                let isOnBoardingCompleted = process.database!.getOnBoardingCompleted()
                let selectedUSExaminationTypeId = process.database!.getSelectedUSExaminationTypeId()
                if isOnBoardingCompleted, selectedUSExaminationTypeId != nil {
                    return process.initialScreen = .scan
                }
                process.initialScreen = .onBoarding
            }
        ),
    ]
}

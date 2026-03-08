import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let postSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Check selected ultrasound examination type",
            run: { (process: InitializationProcess) in
                @MainActor
                func setDefault() {
                    process.usExaminationRepository!.setSelectedUSExaminationTypeId(
                        id: process.usExaminationTypeDefault!.id
                    )
                }
                
                let usExaminationTypeId = process.usExaminationRepository!.getSelectedUSExaminationTypeId()
                guard (usExaminationTypeId != nil) else {
                    return
                }
                
                let matchedId = process.usExaminationTypesById![usExaminationTypeId!]
                guard (matchedId != nil) else {
                    return setDefault()
                }
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Check selected ultrasound selected neural model",
            run: { (process: InitializationProcess) in
                @MainActor
                func setDefault() {
                    process.modelRepository!.setSelectedUSExaminationNeuralModelId(
                        id: process.usExaminationNeuralModelDefault!.id
                    )
                }
                
                let selectedUSExaminationNeuralModelId = process.modelRepository!.getSelectedUSExaminationNeuralModelId()
                guard (selectedUSExaminationNeuralModelId != nil) else {
                    return setDefault()
                }
                
                let matchedId = process.usExaminationNeuralModelsById![selectedUSExaminationNeuralModelId!]
                guard (matchedId != nil) else {
                    return setDefault()
                }
            }
        ),
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

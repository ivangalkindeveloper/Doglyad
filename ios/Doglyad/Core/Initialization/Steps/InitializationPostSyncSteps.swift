import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let postSyncSteps: [SyncInitializationStep<InitializationProcess>] = [
        SyncInitializationStep<InitializationProcess>(
            title: "Check selected ultrasound examination type",
            run: { (process: InitializationProcess) in
                @MainActor
                func setDefault() {
                    process.ultrasoundConclusionRepository!.setSelectedExaminationTypeId(
                        id: process.usExaminationTypeDefault!.id
                    )
                }

                let usExaminationTypeId = process.ultrasoundConclusionRepository!.getSelectedExaminationTypeId()
                guard usExaminationTypeId != nil else {
                    return
                }

                let matchedId = process.usExaminationTypesById![usExaminationTypeId!]
                guard matchedId != nil else {
                    return setDefault()
                }
            }
        ),
        SyncInitializationStep<InitializationProcess>(
            title: "Check selected ultrasound selected neural model",
            run: { (process: InitializationProcess) in
                @MainActor
                func setDefault() {
                    process.ultrasoundModelRepository!.setSelectedModelId(
                        id: process.usExaminationNeuralModelDefault!.id
                    )
                }

                let selectedUSExaminationNeuralModelId = process.ultrasoundModelRepository!.getSelectedModelId()
                guard selectedUSExaminationNeuralModelId != nil else {
                    return setDefault()
                }

                let matchedId = process.usExaminationNeuralModelsById![selectedUSExaminationNeuralModelId!]
                guard matchedId != nil else {
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

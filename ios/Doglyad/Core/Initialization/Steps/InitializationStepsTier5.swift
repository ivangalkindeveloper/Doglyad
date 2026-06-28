import DependencyInitializer
import Foundation

extension InitializationProcess {
    static let stepsTier5 = StepSet(
        sync: [
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

                    let selectedModel = process.usExaminationNeuralModelsById![selectedUSExaminationNeuralModelId!]
                    guard let selectedModel else {
                        return setDefault()
                    }

                    @MainActor
                    func selectFirstBaseModel() {
                        let firstBaseModel = process.usExaminationNeuralModels!.first(where: {
                            $0.entitlement == .base
                        })
                        process.ultrasoundModelRepository!.setSelectedModelId(
                            id: (firstBaseModel ?? process.usExaminationNeuralModelDefault!).id
                        )
                    }
                    
                    let activeSubscriptionType = process.initialSubscriptionStatus?.type
                    let isModelAvailable = selectedModel.entitlement == .base
                        || selectedModel.entitlement == activeSubscriptionType
                    guard isModelAvailable else {
                        return selectFirstBaseModel()
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
                    if !isOnBoardingCompleted || selectedUSExaminationTypeId == nil {
                        return process.initialScreen = .onBoarding
                    }

                    if process.initialUltraSoundConclusions!.isEmpty {
                        return process.initialScreen = .subscriptionPaywall
                    }

                    process.initialScreen = .scan
                }
            ),
        ]
    )
}

enum ScreenType: Hashable {
    case newVersion
    case onBoarding
    case scan
    case history
    case conclusion
    case settings
    case neuralModel
    case templateList
    case templateAdd
    case templateEdit
    case storage
    case userSettings
    case subscriptionPaywall
}

enum SheetType: Hashable {
    case selectUSExaminationType
    case selectNeuralModel
    case selectDateOfBirth
    case scanSpeech
    case requestLimitExceeded
    case permissionSpeech
    case recievedConclusion
    case webDocument
    case storageClearConclusions
    case storageClearAll
    case about
    case share
    case subscriptionCustomerCenter
}

enum FullScreenCoverType: Hashable {}

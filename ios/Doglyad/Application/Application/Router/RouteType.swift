enum ScreenType: Hashable {
    case onBoarding
    case scan
    case history
    case conclusion
    case settings
    case neuralModel
    case storage
}

enum SheetType: Hashable {
    case selectResearchType
    case selectDateOfBirth
    case scanSpeech
    case permissionSpeech
    case webDocument
    case storageClearConclusions
    case storageClearAll
}

enum FullScreenCoverType: Hashable {}

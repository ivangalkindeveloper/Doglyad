enum ScreenType: Hashable {
    case newVersion
    case onBoarding
    case scan
    case history
    case conclusion
    case settings
    case neuralModel
    case storage
}

enum SheetType: Hashable {
    case selectUSExaminationType
    case selectDateOfBirth
    case scanSpeech
    case permissionSpeech
    case webDocument
    case storageClearConclusions
    case storageClearAll
    case about
}

enum FullScreenCoverType: Hashable {}

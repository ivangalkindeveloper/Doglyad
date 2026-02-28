import Router
import SwiftUI

final class RouterBuilder: RouterBuilderProtocol {
    typealias Screen = ScreenType
    typealias Sheet = SheetType
    typealias FullScreenCover = FullScreenCoverType
    typealias Content = AnyView

    func build(
        route: RouteScreen<ScreenType>
    ) -> AnyView {
        switch route.type {
        case .newVersion:
            AnyView(
                NewVersionScreen(
                    arguments: route.arguments as? NewVersionScreenArguments
                )
            )
        case .onBoarding:
            AnyView(
                OnBoardingScreen(
                    arguments: route.arguments as? OnBoardingScreenArguments
                )
            )
        case .scan:
            AnyView(
                ScanScreen(
                    arguments: route.arguments as? ScanScreenArguments
                )
            )
        case .history:
            AnyView(
                HistoryScreen(
                    arguments: route.arguments as? HistoryScreenArguments
                )
            )
        case .conclusion:
            AnyView(
                ConclusionScreen(
                    arguments: route.arguments as! ConclusionScreenArguments
                )
            )
        case .settings:
            AnyView(
                SettingsScreen(
                    arguments: route.arguments as? SettingsScreenArguments
                )
            )
        case .neuralModel:
            AnyView(
                NeuralModelScreen(
                    arguments: route.arguments as? NeuralModelScreenArguments
                )
            )
        case .storage:
            AnyView(
                StorageScreen(
                    arguments: route.arguments as? StorageScreenArguments
                )
            )
        }
    }

    func build(
        route: RouteSheet<SheetType>
    ) -> AnyView {
        switch route.type {
        case .selectUSExaminationType:
            AnyView(
                SelectUSExaminationTypeBottomSheet(
                    arguments: route.arguments as? SelectUSExaminationTypeArguments
                )
            )
        case .selectDateOfBirth:
            AnyView(
                SelectDateOfBirthBottomSheet(
                    arguments: route.arguments as? SelectDateOfBirthArguments
                )
            )
        case .scanSpeech:
            AnyView(
                ScanSpeechBottomSheet(
                    arguments: route.arguments as! ScanSpeechBottomSheetArguments
                )
            )
        case .permissionSpeech:
            AnyView(
                PermissionSpeechBottomSheet()
            )
        case .webDocument:
            AnyView(
                WebDocumentBottomSheet(
                    arguments: route.arguments as! WebDocumentBottomSheetArguments
                )
            )
        case .storageClearConclusions:
            AnyView(
                StorageClearConclusionsBottomSheet(
                    arguments: route.arguments as? StorageClearConclusionsArguments
                )
            )
        case .storageClearAll:
            AnyView(
                StorageClearAllBottomSheet(
                    arguments: route.arguments as? StorageClearAllArguments
                )
            )
        case .about:
            AnyView(AboutBottomSheet())
        }
    }

    func build(
        route: RouteFullScreenCover<FullScreenCoverType>
    ) -> AnyView {
        switch route.type {}
    }
}

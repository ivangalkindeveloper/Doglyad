import SwiftUI
import Router

final class RouterBuilder: RouterBuilderProtocol {
    typealias Screen = ScreenType
    typealias Sheet = SheetType
    typealias FullScreenCover = FullScreenCoverType
    typealias Content = AnyView
    
    func build(
        route: RouteScreen<ScreenType>
    ) -> AnyView {
        switch route.type {
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
        }
    }
    
    func build(
        route: RouteSheet<SheetType>
    ) -> AnyView {
        switch route.type {
        case .selectResearchType:
            AnyView(
                SelectResearchTypeBottomSheet(
                    arguments: route.arguments as? SelectResearchTypeArguments
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
        }
    }
    
    func build(
        route: RouteFullScreenCover<FullScreenCoverType>
    ) -> AnyView {
        switch route.type {}
    }
}

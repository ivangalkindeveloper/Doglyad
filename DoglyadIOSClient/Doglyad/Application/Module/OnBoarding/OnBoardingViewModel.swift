import Foundation
import SwiftUI
import Router

@MainActor
final class OnBoardingViewModel: ObservableObject {
    var diagnosticRepository: DiagnosticsRepositoryProtocol?
    var router: DRouter?
    
    @Published var page: Page = .intro
    
    func onPressedNext() -> Void {
        switch page {
        case .intro:
            page = .researchType
            
        case .researchType:
            router?.push(
                route: RouteSheet(
                    type: .selectResearchType,
                    arguments: SelectResearchTypeArguments(
                        onSelected: { [weak self] researchType in
                            self?.page = .scan
                            self?.diagnosticRepository?.setSelectedResearchType(
                                type: researchType
                            )
                        }
                    )
                )
            )
            
        case .scan:
            diagnosticRepository?.setOnBoardingCompleted(
                value: true
            )
            withAnimation {
                router?.root(
                    route: RouteScreen(
                        type: .scan
                    )
                )
            }
        }
    }
}

extension OnBoardingViewModel {
    enum Page {
        case intro
        case researchType
        case scan
    }
}

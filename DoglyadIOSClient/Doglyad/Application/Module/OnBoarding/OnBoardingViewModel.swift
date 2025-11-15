import Foundation
import SwiftUI
import Router

@MainActor
final class OnBoardingViewModel: ObservableObject {
    private var diagnosticRepository: DiagnosticsRepositoryProtocol
    private var router: DRouter
    
    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.router = router
        self.page = page
    }
    
    @Published var page: Page = .intro
    
    func buttonTitle(
        _ page: OnBoardingViewModel.Page
    ) -> LocalizedStringResource {
        switch page {
        case .intro:
            .buttonNext
        case .researchType:
            .buttonSelectType
        case .scan:
            .buttonStart
        }
    }
    
    func onPressedNext() -> Void {
        switch page {
        case .intro:
            page = .researchType
            
        case .researchType:
            router.push(
                route: RouteSheet(
                    type: .selectResearchType,
                    arguments: SelectResearchTypeArguments(
                        onSelected: { [weak self] researchType in
                            self?.page = .scan
                            self?.diagnosticRepository.setSelectedResearchType(
                                type: researchType
                            )
                        }
                    )
                )
            )
            
        case .scan:
            diagnosticRepository.setOnBoardingCompleted(
                value: true
            )
            withAnimation {
                router.root(
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

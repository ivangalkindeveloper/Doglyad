import Foundation
import SwiftUI
import Router

@MainActor
final class OnBoardingViewModel: ObservableObject {
    private let sharedRepository: SharedRepositoryProtocol
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let router: DRouter
    
    init(
        sharedRepository: SharedRepositoryProtocol,
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        router: DRouter
    ) {
        self.sharedRepository = sharedRepository
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
                            guard let self = self else { return }
                            
                            self.page = .scan
                            self.diagnosticRepository.setSelectedResearchType(
                                type: researchType
                            )
                        }
                    )
                )
            )
            
        case .scan:
            sharedRepository.setOnBoardingCompleted(
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

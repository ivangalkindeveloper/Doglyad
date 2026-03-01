import Foundation
import Router
import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    private let usExaminationRepository: USExaminationRepositoryProtocol
    private let router: DRouter

    init(
        usExaminationRepository: USExaminationRepositoryProtocol,
        router: DRouter
    ) {
        self.usExaminationRepository = usExaminationRepository
        self.router = router
        onInit()
    }

    @Published var conclusions: [USExaminationConclusion] = []

    private func onInit() {
        let conclusions = usExaminationRepository.getConclusions()
        self.conclusions = conclusions
    }

    func onTapBack() {
        router.pop()
    }

    func onTapConclusion(
        value: USExaminationConclusion
    ) {
        router.push(
            route: RouteScreen(
                type: .conclusion,
                arguments: ConclusionScreenArguments(
                    conclusion: value
                )
            )
        )
    }
}

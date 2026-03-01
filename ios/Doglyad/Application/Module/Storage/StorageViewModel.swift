import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
final class StorageViewModel: ObservableObject {
    private let usExaminationRepository: USExaminationRepositoryProtocol
    private let messager: DMessager
    private let router: DRouter

    init(
        usExaminationRepository: USExaminationRepositoryProtocol,
        messager: DMessager,
        router: DRouter
    ) {
        self.usExaminationRepository = usExaminationRepository
        self.messager = messager
        self.router = router
    }

    func onTapBack() {
        router.pop()
    }

    func onTapClearConclusions() {
        router.push(
            route: RouteSheet(
                type: .storageClearConclusions,
                arguments: StorageClearConclusionsArguments(
                    onConfirm: { [weak self] in
                        guard let self = self else { return }

                        self.usExaminationRepository.clearAllConclusions()
                        self.messager.show(
                            type: .success,
                            title: .storageClearConclusionsSuccessMessageTitle,
                            description: .storageClearConclusionsSuccessMessageDescription
                        )
                        self.router.pop()
                    }
                )
            )
        )
    }

    func onTapClearAll() {
        router.push(
            route: RouteSheet(
                type: .storageClearAll,
                arguments: StorageClearAllArguments(
                    onConfirm: { [weak self] in
                        guard let self = self else { return }

                        self.usExaminationRepository.clearAll()
                        self.messager.show(
                            type: .success,
                            title: .storageClearAllSuccessMessageTitle,
                            description: .storageClearAllSuccessMessageDescription
                        )
                        self.router.popRoot()
                        withAnimation {
                            self.router.root(
                                route: RouteScreen(
                                    type: .onBoarding
                                )
                            )
                        }
                    }
                )
            )
        )
    }
}

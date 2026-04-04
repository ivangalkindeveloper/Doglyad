import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class StorageViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter
    ) {
        self.container = container
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

                        self.container.usExaminationRepository.clearAllConclusions()
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

                        self.container.usExaminationRepository.clearAll()
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

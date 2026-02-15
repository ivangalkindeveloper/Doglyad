import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
final class StorageViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let messanger: DMessager
    private let router: DRouter

    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        messanger: DMessager,
        router: DRouter
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.messanger = messanger
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

                        self.diagnosticRepository.clearAllConclusions()
                        self.messanger.show(
                            type: .success,
                            title: .storageClearConclusionsSuccessMessage
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

                        self.diagnosticRepository.clearAll()
                        self.messanger.show(
                            type: .success,
                            title: .storageClearAllSuccessMessage
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

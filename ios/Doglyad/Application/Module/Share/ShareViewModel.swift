import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import NestedObservableObject
import Router
import UIKit

@MainActor
final class ShareViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: ShareArguments
    @NestedObservableObject private var subscription: SubscriptionViewModel
    let userEmail: String?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: ShareArguments,
        subscription: SubscriptionViewModel,
        userEmail: String?
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        _subscription = NestedObservableObject(wrappedValue: subscription)
        self.userEmail = userEmail
        super.init()
    }

    @Published var isLoading = false

    var isUserEmailAvailable: Bool {
        userEmail != nil
    }

    var isUserEmailButtonVisible: Bool {
        switch subscription.availability(of: .sendingConclusionByEmail) {
        case .offered, .available:
            return true
        case .unavailable:
            return false
        }
    }

    var userEmailButtonTitle: String {
        "\(String(localized: .buttonShareUserEmailPrefix)) \(userEmail ?? "")"
    }

    var subject: String {
        arguments.conclusion.shareSubject(
            examinationTypesById: container.usExaminationTypesById
        )
    }

    var shareMessage: String {
        arguments.conclusion.shareMessage
    }

    func onTapUserEmail() {
        guard let userEmail = userEmail else { return }
        subscription.run(.sendingConclusionByEmail, router: router, dismissesSheetOnPaywall: true) {
            self.sendConclusionEmail(to: userEmail)
        }
    }

    private func sendConclusionEmail(to userEmail: String) {
        handle {
            self.isLoading = true
            try await self.container.userSettingsRepository.sendEmail(
                email: USExaminationEmail(
                    recipientEmail: userEmail,
                    subject: self.subject,
                    body: self.shareMessage
                )
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { _ in
            self.router.dismissSheet()
            self.messager.show(
                type: .success,
                title: .shareUserEmailSuccessMessageTitle,
                description: .shareUserEmailSuccessMessageDescription
            )
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }

    func onTapEmail() {
        subscription.run(.sendingConclusionByEmail, router: router, dismissesSheetOnPaywall: true) {
            self.router.dismissSheet()
            UIApplication.openMail(
                subject: self.subject,
                body: self.shareMessage
            )
        }
    }

    func onTapCopy() {
        router.dismissSheet()
        UIApplication.pasteboard(shareMessage)
        messager.show(
            type: .success,
            title: .shareExaminationCopyMessageTitle,
            description: .shareExaminationCopyMessageDescription
        )
    }
}

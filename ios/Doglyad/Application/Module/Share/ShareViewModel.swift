import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import Router
import UIKit

@MainActor
final class ShareViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: ShareArguments
    private let getSendingConclusionByEmailAvailability: () -> SubscriptionFeatureAvailability
    let userEmail: String?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: ShareArguments,
        getSendingConclusionByEmailAvailability: @escaping () -> SubscriptionFeatureAvailability,
        userEmail: String?
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        self.getSendingConclusionByEmailAvailability = getSendingConclusionByEmailAvailability
        self.userEmail = userEmail
        super.init()
    }

    @Published var isLoading = false

    var isUserEmailAvailable: Bool {
        userEmail != nil
    }

    var isUserEmailButtonVisible: Bool {
        switch getSendingConclusionByEmailAvailability() {
        case .offered, .available:
            return true
        case .unavailable:
            return false
        }
    }

    var isUserEmailProBadgeVisible: Bool {
        switch getSendingConclusionByEmailAvailability() {
        case .offered:
            return true
        case .available, .unavailable:
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
        switch getSendingConclusionByEmailAvailability() {
        case .available:
            break
        case .offered:
            router.dismissSheet()
            return router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
        case .unavailable:
            return
        }

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
        switch getSendingConclusionByEmailAvailability() {
        case .available:
            break
        case .offered:
            router.dismissSheet()
            return router.push(
                route: RouteScreen(
                    type: .subscriptionPaywall
                )
            )
        case .unavailable:
            return
        }

        router.dismissSheet()
        UIApplication.openMail(
            subject: subject,
            body: shareMessage
        )
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

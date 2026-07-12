import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import NestedObservableObject
import Router
import SwiftUI
import UIKit

@MainActor
final class RecievedConclusionViewModel: DViewModel {
    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter
    private let arguments: RecievedConclusionBottomSheetArguments
    @NestedObservableObject private var subscription: SubscriptionViewModel
    let userEmail: String?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: RecievedConclusionBottomSheetArguments,
        subscription: SubscriptionViewModel,
        userEmail: String?
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        _subscription = NestedObservableObject(wrappedValue: subscription)
        self.userEmail = userEmail
    }

    @Published var displayedResponse = ""
    @Published var isLoading = false
    private var typewriterTask: Task<Void, Never>?

    var model: USExaminationModelConclusion {
        arguments.conclusion.actualModelConclusion
    }

    var response: String {
        arguments.conclusion.actualModelConclusion.response
    }

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

    var userEmailButtonTitle: LocalizedStringResource {
        "\(String(localized: .buttonShareUserEmailPrefix)) \(userEmail ?? "")"
    }

    override func onInit() {
        startTypewriterAnimation()
    }

    private func startTypewriterAnimation() {
        typewriterTask?.cancel()

        let words = response.components(separatedBy: " ")
        typewriterTask = Task {
            for (index, word) in words.enumerated() {
                if Task.isCancelled { return }
                let separator = index == 0 ? "" : " "
                displayedResponse.append(separator + word)
                try? await Task.sleep(nanoseconds: 60000000)
            }
        }
    }

    func onTapConclusion() {
        router.dismissSheet()
        router.push(
            route: RouteScreen(
                type: .conclusion,
                arguments: ConclusionScreenArguments(
                    conclusion: arguments.conclusion
                )
            )
        )
    }

    func onTapUserEmail() {
        guard let userEmail: String = userEmail else { return }
        subscription.run(
            .sendingConclusionByEmail,
            router: router,
            dismissesSheetOnPaywall: true
        ) {
            self.sendConclusionEmail(to: userEmail)
        }
    }

    private func sendConclusionEmail(to userEmail: String) {
        let conclusion = arguments.conclusion
        let subject = conclusion.shareSubject(
            examinationTypesById: container.usExaminationTypesById
        )
        let shareMessage = conclusion.shareMessage
        handle {
            self.isLoading = true
            try await self.container.userSettingsRepository.sendEmail(
                email: USExaminationEmail(
                    recipientEmail: userEmail,
                    subject: subject,
                    body: shareMessage
                )
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { _ in
            self.messager.show(
                type: .success,
                title: .shareUserEmailSuccessMessageTitle,
                description: .shareUserEmailSuccessMessageDescription
            )
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }

    func onTapCopy() {
        UIApplication.pasteboard(response)
        messager.show(
            type: .success,
            title: .conclusionModelCopyMessageTitle,
            description: .conclusionModelCopyMessageDescription
        )
    }
}

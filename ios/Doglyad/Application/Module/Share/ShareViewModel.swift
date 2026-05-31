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
    let userEmail: String?

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter,
        arguments: ShareArguments,
        userEmail: String?
    ) {
        self.container = container
        self.messager = messager
        self.router = router
        self.arguments = arguments
        self.userEmail = userEmail
        super.init()
    }

    @Published var isLoading = false

    var isUserEmailAvailable: Bool {
        userEmail != nil
    }

    var userEmailButtonTitle: String {
        "\(String(localized: .buttonShareUserEmailPrefix)) \(userEmail ?? "")"
    }

    var shareContent: String {
        let conclusion = arguments.conclusion
        let examinationData = conclusion.examinationData
        return """
        \(conclusion.date.localized())

        \(examinationData.patientName)

        \(conclusion.actualModelConclusion.response)
        """
    }

    func onTapUserEmail() {
        guard let userEmail = userEmail else { return }
        let conclusion = arguments.conclusion
        handle {
            self.isLoading = true
            try await self.container.userSettingsRepository.sendEmail(
                email: USExaminationEmail(
                    recipientEmail: userEmail,
                    examinationData: conclusion.examinationData,
                    modelConclusion: conclusion.actualModelConclusion
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
        router.dismissSheet()
        UIApplication.openMail(
            subject: arguments.conclusion.examinationData.patientName,
            body: shareContent
        )
    }

    func onTapCopy() {
        router.dismissSheet()
        UIApplication.pasteboard(shareContent)
        messager.show(
            type: .success,
            title: .shareCopyMessageTitle,
            description: .shareCopyMessageDescription
        )
    }
}

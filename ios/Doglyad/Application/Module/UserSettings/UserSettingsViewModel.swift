import DoglyadUI
import Foundation
import NestedObservableObject
import Router
import SwiftUI

@MainActor
final class UserSettingsViewModel: DViewModel {
    enum Focus: Hashable {
        case email
    }

    private let messager: DMessager
    private let router: DRouter
    private let onEmailSaved: (String) -> Void

    init(
        initialEmail: String,
        messager: DMessager,
        router: DRouter,
        onEmailSaved: @escaping (String) -> Void
    ) {
        self.messager = messager
        self.router = router
        self.onEmailSaved = onEmailSaved
        super.init()
        emailController.text = initialEmail
    }

    @Published var focus: Focus?
    @NestedObservableObject var emailController = DTextFieldController()

    func onTapBack() {
        router.pop()
    }

    func unfocus() {
        focus = nil
    }

    func onSubmit() {
        switch focus {
        case .email, .none:
            focus = nil
        }
    }

    func onTapSave() {
        unfocus()

        let email = emailController.text.trimmingCharacters(in: .whitespacesAndNewlines)
        onEmailSaved(email)
        messager.show(
            type: .success,
            title: .userSettingsSavedSuccessMessageTitle,
            description: .userSettingsSavedSuccessMessageDescription
        )
        router.pop()
    }
}

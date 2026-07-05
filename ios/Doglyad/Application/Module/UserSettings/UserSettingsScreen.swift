import DoglyadUI
import Router
import SwiftUI

struct UserSettingsScreen: View {
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var ultrasoundViewModel: UltrasoundViewModel
    @EnvironmentObject private var router: DRouter
    let arguments: UserSettingsScreenArguments?

    var body: some View {
        UserSettingsScreenView(
            viewModel: UserSettingsViewModel(
                messager: messager,
                router: router,
                initialEmail: ultrasoundViewModel.userEmail,
                onEmailSaved: { [ultrasoundViewModel] email in
                    ultrasoundViewModel.saveUserEmail(userEmail: email)
                }
            )
        )
    }
}

#Preview {
    UserSettingsScreen(
        arguments: nil
    )
    .previewable()
}

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
                initialEmail: ultrasoundViewModel.email,
                messager: messager,
                router: router,
                onEmailSaved: { [weak ultrasoundViewModel] email in
                    ultrasoundViewModel?.saveEmail(email)
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

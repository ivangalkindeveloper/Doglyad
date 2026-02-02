import DoglyadUI
import Router
import SwiftUI

final class SettingsScreenArguments: RouteArgumentsProtocol {}

struct SettingsScreen: View {
    @EnvironmentObject private var router: DRouter
    let arguments: SettingsScreenArguments?

    var body: some View {
        SettingsScreenView(
            viewModel: SettingsViewModel(
                router: router
            )
        )
    }
}

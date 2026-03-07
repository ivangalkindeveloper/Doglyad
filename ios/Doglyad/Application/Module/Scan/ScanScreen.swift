import DoglyadUI
import Router
import SwiftUI

struct ScanScreen: View {
    @EnvironmentObject private var container: DependencyContainer
    @EnvironmentObject private var messager: DMessager
    @EnvironmentObject private var router: DRouter
    let arguments: ScanScreenArguments?

    var body: some View {
        ScanScreenView(
            viewModel: ScanViewModel(
                environment: container.environment,
                permissionManager: container.permissionmanager,
                modelRepository: container.modelRepository,
                usExaminationRepository: container.usExaminationRepository,
                usExaminationTypesById: container.usExaminationTypesById,
                usExaminationTypeDefault: container.usExaminationTypeDefault,
                messager: messager,
                router: router
            )
        )
    }
}

#Preview {
    ScanScreen(
        arguments: nil
    )
    .previewable()
}

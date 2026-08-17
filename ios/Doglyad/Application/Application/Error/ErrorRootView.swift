import DoglyadUI
import SwiftUI

struct ErrorRootView: View {
    @EnvironmentObject private var viewModel: ApplicationViewModel
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let error: Error

    var body: some View {
        let error = error as? InitializationError
        switch error {
        case .noInternetConnection:
            ErrorView(
                title: .errorNoInternetConnectionTitle,
                buttonTitle: .buttonUpdate,
                action: viewModel.initialize
            ) { _ in
                DText(.errorNoInternetConnectionDescription)
            }
        case .noCameraRequestDenied:
            ErrorView(
                title: .errorNoCameraPermissionTitle,
                buttonTitle: .buttonOpenSettings,
                action: viewModel.openSettings
            ) { _ in
                DText(.errorNoCameraPermissionDescription)
            }
        case let .serviceUnavailable(email):
            ErrorView(
                email: email,
                title: .serviceUnavailableTitle
            ) { viewModel in
                VStack(
                    spacing: size.s8
                ) {
                    DText(.serviceUnavailableDescription)

                    Button(
                        action: viewModel.onTapEmail
                    ) {
                        DText(viewModel.email ?? email)
                            .dStyle(
                                font: typography.linkSmall,
                                color: color.primaryDefault,
                                alignment: .center
                            )
                            .padding(.vertical, size.s4)
                    }
                    .buttonStyle(.plain)
                }
            }
        case .usExaminationTypesEmpty,
             .usExaminationNeuralModelsEmpty,
             .examinationNeuralModelPromptEmpty,
             .some(.common),
             .none:
            ErrorView(
                title: .errorUnknownTitle,
                buttonTitle: .buttonUpdate,
                action: viewModel.initialize
            ) { _ in
                DText(.errorUnknownDescription)
            }
        }
    }
}

#Preview {
    ErrorRootView(
        error: InitializationError.noInternetConnection
    )
    .previewable()
}

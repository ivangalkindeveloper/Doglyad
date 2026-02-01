import DoglyadUI
import SwiftUI

struct ErrorRootView: View {
    @EnvironmentObject private var viewModel: ApplicationViewModel

    let error: Error

    var body: some View {
        let error = error as? InitializationError
        switch error {
        case .noInternetConnection:
            ErrorView(
                error: self.error,
                image: .wifi,
                title: .errorNoInternetConnectionTitle,
                description: .errorNoInternetConnectionDescription,
                buttonTitle: .buttonUpdate,
                action: viewModel.initialize
            )
        case .noCameraRequestDenied:
            ErrorView(
                error: self.error,
                image: .camera,
                title: .errorNoCameraPermissionTitle,
                description: .errorNoCameraPermissionDescription,
                buttonTitle: .buttonOpenSettings,
                action: viewModel.openSettings
            )
        case .some(.common), .none:
            ErrorView(
                error: self.error,
                image: .alertInfo,
                title: .errorUnknownTitle,
                description: .errorUnknownDescription,
                buttonTitle: .buttonUpdate,
                action: viewModel.initialize
            )
        }
    }
}

private struct ErrorView: View {
    @EnvironmentObject private var viewModel: ApplicationViewModel
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let error: Error
    let image: ImageResource
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let buttonTitle: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        DScreen { _ in
            VStack(
                spacing: .zero
            ) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(color.gradientPrimaryWeak)
                    DIcon(
                        image,
                        color: color.grayscaleBackground
                    )
                }
                .frame(width: size.s64, height: size.s64)
                .padding(.bottom, size.s16)
                DText(
                    title
                )
                .dStyle(
                    font: theme.typography.linkMedium,
                    alignment: .center
                )
                .padding(.bottom, size.s10)
                DText(
                    description
                )
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlaceholder,
                    alignment: .center
                )
                .padding(.horizontal, size.s14)
                .padding(.bottom, size.s14)
                Spacer()
                DButton(
                    title: buttonTitle,
                    action: self.action,
                    isLoading: self.viewModel.isLoading
                )
                .dStyle(.primaryButton)
            }
            .padding(size.s16)
        }
    }
}

#Preview {
    ApplicationWrapperView {
        DThemeWrapperView {
            ErrorRootView(
                error: InitializationError.noInternetConnection
            )
        }
    }
}

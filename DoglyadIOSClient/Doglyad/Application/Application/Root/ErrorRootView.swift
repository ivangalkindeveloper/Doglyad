//
//  ErrorRootView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import DoglyadUI
import SwiftUI

struct ErrorRootView: View {
    let error: Error
    @StateObject var state: ApplicationState

    var body: some View {
        let error = error as? InitializationError

        switch error {
        case .noInternetConnection:
            ErrorView(
                image: .wifi,
                title: .errorNoInternetConnectionTitle,
                description: .errorNoInternetConnectionDescription,
                state: self.state
            )
        case .noCameraRequestDenied:
            ErrorView(
                image: .camera,
                title: .errorNoCameraPermissionTitle,
                description: .errorNoCameraPermissionDescription,
                state: self.state
            )
        default:
            ErrorView(
                image: .alertInfo,
                title: .errorUnknownTitle,
                description: .errorUnknownDescription,
                state: self.state
            )
        }
    }
}

private struct ErrorView: View {
    @EnvironmentObject var theme: DTheme
    var color: DColor { theme.color }
    var size: DSize { theme.size }
    var typography: DTypography { theme.typography }

    let image: ImageResource
    let title: L10n
    let description: L10n
    @StateObject var state: ApplicationState
    
    var body: some View {
        DScreen(
            body: VStack(
                spacing: 0,
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
                    title.string,
                )
                .dStyle(
                    font: theme.typography.linkMedium,
                    alignment: .center
                )
                .padding(.bottom, size.s10)
                DText(
                    description.string,
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
                    title: L10n.buttonUpdate.string,
                    action: self.state.initialize,
                    isLoading: self.state.isLoading
                )
            }
            .padding(size.s16)
        )
    }
}

#Preview {
    DThemeWrapperView(
        ErrorRootView(
            error: InitializationError.noInternetConnection,
            state: ApplicationState(),
        )
    )
}

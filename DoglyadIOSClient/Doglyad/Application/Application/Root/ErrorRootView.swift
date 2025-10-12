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

    var body: some View {
        let error = error as? InitializationError

        switch error {
        case .noInternetConnection:
            ErrorView(
                image: .wifi,
                title: .errorNoInternetConnectionTitle,
                description: .errorNoInternetConnectionDescription,
            )
        case .noCameraRequestDenied:
            ErrorView(
                image: .camera,
                title: .errorNoCameraPermissionTitle,
                description: .errorNoCameraPermissionDescription,
            )
        default:
            ErrorView(
                image: .alertInfo,
                title: .errorUnknownTitle,
                description: .errorUnknownDescription,
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
                .padding(.bottom, size.s14)
                DText(
                    title.string,
                )
                .dStyle(
                    alignment: .center
                )
                .padding(.bottom, size.s14)
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
                    action: {},
                )
            }
            .padding(size.s16)
        )
    }
}

#Preview {
    DThemeWrapperView(
        ErrorRootView(
            error: InitializationError.noInternetConnection
        )
    )
}

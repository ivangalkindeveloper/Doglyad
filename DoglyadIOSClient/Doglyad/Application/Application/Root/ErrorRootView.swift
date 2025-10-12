//
//  ErrorRootView.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import SwiftUI
import DoglyadUI

struct ErrorRootView: View {
    let error: Error

    var body: some View {
        let error = error as? InitializationError

        switch error {
        case .noInternetConnection:
            ErrorView(
                image: .wifi,
                title: L10n.errorNoInternetConnectionTitle,
                description: L10n.errorNoInternetConnectionDescription,
            )
        case .noCameraRequestDenied:
            ErrorView(
                image: .camera,
                title: L10n.errorNoCameraPermissionTitle,
                description: L10n.errorNoCameraPermissionDescription,
            )
        default:
            ErrorView(
                image: .alertInfo,
                title: L10n.errorUnknownTitle,
                description: L10n.errorUnknownDescription,
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
        VStack(
            spacing: 0,
        ) {
            Spacer()
            ZStack {
                Circle()
                    .fill(color.gradientAccent)
                Image(image)
            }
                .frame(width: size.s64, height: size.s64)
                .padding(.bottom, size.s14)
            Text(title.string)
                .font(typography.displayHuge)
                .padding(.bottom, size.s14)
                .multilineTextAlignment(.center)
            Text(description.string)
                .font(typography.textMedium)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(size.s16)
    }
}

#Preview {
    ThemeWrapperView(
        ErrorRootView(
            error: InitializationError.noCameraRequestDenied
        )
    )
}

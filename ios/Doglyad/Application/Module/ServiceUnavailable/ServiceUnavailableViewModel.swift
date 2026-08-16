import DoglyadUI
import Foundation
import SwiftUI

@MainActor
final class ServiceUnavailableViewModel: DViewModel {
    private let container: DependencyContainer

    init(
        container: DependencyContainer
    ) {
        self.container = container
        super.init()
    }

    func descriptionAttributedText(
        theme: DTheme,
        locale: Locale
    ) -> AttributedString {
        let typography: DTypography = theme.typography
        let color: DColor = theme.color

        var description = AttributedString(
            localizedResource(
                .serviceUnavailableDescription,
                locale: locale
            )
        )
        description.font = typography.textMedium
        description.foregroundColor = color.grayscaleHeader

        let contactEmail = container.applicationConfig.contactEmail
        var email = AttributedString(contactEmail)
        email.font = typography.textMedium
        email.foregroundColor = color.primaryDefault
        email.link = URL(string: "mailto:\(contactEmail)")

        return description + " " + email
    }

    private func localizedResource(
        _ resource: LocalizedStringResource,
        locale: Locale
    ) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}

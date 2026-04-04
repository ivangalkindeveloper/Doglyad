import DoglyadUI
import SwiftUI

struct AboutBottomSheet: View {
    @Environment(\.locale) private var locale: Locale
    @Environment(DependencyContainer.self) private var dependencyContainer
    @Environment(DTheme.self) private var theme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    private func contactAttributedText() -> AttributedString {
        var description = AttributedString(localizedResource(.aboutContactDescription, locale: locale))
        description.font = typography.textSmall
        description.foregroundColor = color.grayscaleHeader

        var email = AttributedString(dependencyContainer.environment.contactEmail)
        email.font = typography.textSmall
        email.foregroundColor = color.primaryDefault
        email.link = URL(string: "mailto:\(email)")

        return description + email
    }

    private func localizedResource(
        _ resource: LocalizedStringResource,
        locale: Locale
    ) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    var body: some View {
        DBottomSheet(
            title: .settingsAboutAppTitle,
            fraction: 0.55
        ) { toolbarHeight in
            VStack(
                spacing: .zero
            ) {
                Image(.alertInfo)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: size.s64,
                        maxHeight: size.s64
                    )
                    .padding(.top, toolbarHeight + size.s16)
                    .padding(size.s16)

                DText(.aboutDescription)
                    .dStyle(
                        font: typography.textSmall,
                        color: color.grayscaleHeader,
                        alignment: .center
                    )
                    .padding(size.s16)

                Spacer()
            }
        } bottom: {
            Text(contactAttributedText())
                .multilineTextAlignment(.center)
                .tint(color.primaryDefault)
                .padding(size.s16)
        }
    }
}

#Preview {
    AboutBottomSheet()
        .previewable()
}

import DoglyadUI
import Foundation
import Router
import SwiftUI

/// Shown when `legalDate` in the configuration is newer than the one the user accepted.
/// Records that a specific revision of the documents was presented to the user.
@MainActor
final class LegalUpdateViewModel: DViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
        super.init()
    }

    @Published var isLegalAccepted: Bool = false

    var isAcceptDisabled: Bool {
        isLegalAccepted == false
    }

    func onTapPrivacyPolicy() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: container.applicationConfig.privacyPolicyUrl,
                    title: .privacyPolicyTitle
                )
            )
        )
    }

    func onTapTermsAndConditions() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: container.applicationConfig.termsAndConditionsUrl,
                    title: .termsAndConditionsTitle
                )
            )
        )
    }

    func onTapAccept() {
        container.sharedRepository.acceptLegal(
            documentDate: container.applicationConfig.legalDate
        )
        withAnimation {
            router.root(
                route: RouteScreen(
                    type: .scan
                )
            )
        }
    }
}

extension LegalUpdateViewModel {
    enum AttributedLinks: String {
        case privacy, terms
    }

    func legalAttributedText(theme: DTheme, locale: Locale) -> AttributedString {
        let typography: DTypography = theme.typography
        let color: DColor = theme.color

        var accept = AttributedString(localizedResource(.onBoardingLegalAcceptDescription, locale: locale))
        accept.font = typography.textSmall
        accept.foregroundColor = color.grayscaleHeader

        var privacy = AttributedString(localizedResource(.onBoardingPrivacyPolicyLabel, locale: locale))
        privacy.font = typography.textSmall
        privacy.foregroundColor = color.primaryDefault
        privacy.link = URL(string: AttributedLinks.privacy.rawValue)

        var and = AttributedString(localizedResource(.onBoardingLegalAcceptAndDescription, locale: locale))
        and.font = typography.textSmall
        and.foregroundColor = color.grayscaleHeader

        var terms = AttributedString(localizedResource(.onBoardingTermsAndConditionsLabel, locale: locale))
        terms.font = typography.textSmall
        terms.foregroundColor = color.primaryDefault
        terms.link = URL(string: AttributedLinks.terms.rawValue)

        return accept + privacy + and + terms
    }

    private func localizedResource(
        _ resource: LocalizedStringResource,
        locale: Locale
    ) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    func onLegalAttributedEnvironment(
        url: URL
    ) -> OpenURLAction.Result {
        switch url.absoluteString {
        case AttributedLinks.privacy.rawValue:
            onTapPrivacyPolicy()
            return .handled
        case AttributedLinks.terms.rawValue:
            onTapTermsAndConditions()
            return .handled
        default:
            return .systemAction
        }
    }
}

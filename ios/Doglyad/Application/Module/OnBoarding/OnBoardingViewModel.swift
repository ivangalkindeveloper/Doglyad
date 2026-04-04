import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class OnBoardingViewModel {
    enum Page {
        case first, second, third, fourth, fifth
    }

    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
    }

    var page: Page = .first
    var isLegalAccepted: Bool = false

    var isLegalDisabled: Bool {
        page == .third && isLegalAccepted == false
    }

    func onTapPrivacyPolicy() {
        router.push(
            route: RouteSheet(
                type: .webDocument,
                arguments: WebDocumentBottomSheetArguments(
                    url: container.environment.privacyPolicyUrl,
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
                    url: container.environment.termsAndConditionsUrl,
                    title: .termsAndConditionsTitle
                )
            )
        )
    }

    func buttonTitle(
        _ page: OnBoardingViewModel.Page
    ) -> LocalizedStringResource {
        switch page {
        case .first, .second:
            .buttonNext
        case .third:
            .buttonAccept
        case .fourth:
            .buttonSelectType
        case .fifth:
            .buttonStart
        }
    }

    func onPressedNext() {
        switch page {
        case .first:
            page = .second

        case .second:
            page = .third

        case .third:
            page = .fourth

        case .fourth:
            router.push(
                route: RouteSheet(
                    type: .selectUSExaminationType,
                    arguments: SelectUSExaminationTypeArguments(
                        onSelected: { [weak self] type in
                            guard let self = self else { return }

                            self.page = .fifth
                            self.container.usExaminationRepository.setSelectedUSExaminationTypeId(
                                id: type.id
                            )
                        }
                    )
                )
            )

        case .fifth:
            container.sharedRepository.setOnBoardingCompleted(
                value: true
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
}

extension OnBoardingViewModel {
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

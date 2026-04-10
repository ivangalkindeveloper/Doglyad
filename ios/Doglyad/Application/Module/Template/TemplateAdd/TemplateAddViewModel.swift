import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class TemplateAddViewModel {
    private let container: DependencyContainer
    private let router: DRouter
    private let messager: DMessager

    init(
        container: DependencyContainer,
        router: DRouter,
        messager: DMessager
    ) {
        self.container = container
        self.router = router
        self.messager = messager
        self.usExaminationType = container.usExaminationTypeDefault
    }

    var usExaminationType: USExaminationType
    var templateController = DTextFieldController()

    func onTapBack() {
        router.pop()
    }

    func onTapExaminationType() {
        router.push(
            route: RouteSheet(
                type: .selectUSExaminationType,
                arguments: SelectUSExaminationTypeArguments(
                    currentValue: usExaminationType,
                    onSelected: { [weak self] type in
                        self?.usExaminationType = type
                    }
                )
            )
        )
    }

    func onTapSave(
        ultrasoundViewModel: UltrasoundViewModel
    ) {
        let content = templateController.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            templateController.showError(
                text: String(localized: .templateAddEmptyContentError)
            )
            return
        }

        let template = USExaminationTemplate(
            id: UUID().uuidString,
            usExaminationType: usExaminationType,
            content: content
        )
        ultrasoundViewModel.saveTemplate(template)
        messager.show(
            type: .success,
            title: .templateSavedSuccessTitle,
            description: .templateSavedSuccessDescription
        )
        router.pop()
    }
}

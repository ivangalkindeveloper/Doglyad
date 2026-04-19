import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class TemplateAddViewModel {
    enum Focus: Hashable {
        case content
    }

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
        usExaminationType = container.usExaminationTypeDefault
    }

    var focus: Focus?
    var usExaminationType: USExaminationType
    var templateController = DTextFieldController()

    func onTapBack() {
        router.pop()
    }

    func unfocus() {
        focus = nil
    }

    func onSubmit() {
        switch focus {
        case .content, .none:
            focus = nil
        }
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
        let isContentValid = templateController.validate()
        guard isContentValid else {
            templateController.showError(
                text: String(localized: .templateAddEmptyContentError)
            )
            return
        }

        let hasTemplateForType = container.templateRepository.getTemplates(
            usExaminationTypesById: container.usExaminationTypesById
        ).contains { $0.usExaminationType.id == usExaminationType.id }
        guard !hasTemplateForType else {
            messager.show(
                type: .error,
                title: .templateAddDuplicateExaminationTypeTitle,
                description: .templateAddDuplicateExaminationTypeDescription
            )
            return
        }

        unfocus()

        let content = templateController.text
        let template = USExaminationTemplate(
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

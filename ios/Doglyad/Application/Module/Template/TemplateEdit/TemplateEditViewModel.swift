import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class TemplateEditViewModel {
    private let container: DependencyContainer
    private let router: DRouter
    private let messager: DMessager
    private let templateId: String

    init(
        container: DependencyContainer,
        router: DRouter,
        messager: DMessager,
        arguments: TemplateEditScreenArguments
    ) {
        self.container = container
        self.router = router
        self.messager = messager
        self.templateId = arguments.templateId
        self.usExaminationType = container.usExaminationTypeDefault
        if let template = container.templateRepository.getTemplate(
            id: arguments.templateId,
            usExaminationTypesById: container.usExaminationTypesById
        ) {
            self.usExaminationType = template.usExaminationType
            self.templateController.text = template.content
        }
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
            id: templateId,
            usExaminationType: usExaminationType,
            content: content
        )
        ultrasoundViewModel.updateTemplate(template)
        messager.show(
            type: .success,
            title: .templateSavedSuccessTitle,
            description: .templateSavedSuccessDescription
        )
        router.pop()
    }

    func onTapDelete(
        ultrasoundViewModel: UltrasoundViewModel
    ) {
        ultrasoundViewModel.deleteTemplate(id: templateId)
        messager.show(
            type: .success,
            title: .templateDeletedSuccessTitle,
            description: .templateDeletedSuccessDescription
        )
        router.pop()
    }
}

import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import NestedObservableObject
import Router
import SwiftUI

@MainActor
final class TemplateEditViewModel: BaseViewModel {
    enum Focus: Hashable {
        case content
    }

    private let container: DependencyContainer
    private let router: DRouter
    private let messager: DMessager
    private let arguments: TemplateEditScreenArguments

    init(
        container: DependencyContainer,
        router: DRouter,
        messager: DMessager,
        arguments: TemplateEditScreenArguments
    ) {
        self.container = container
        self.router = router
        self.messager = messager
        self.arguments = arguments
        usExaminationType = container.usExaminationTypeDefault
    }

    override func onInit() {
        handle {
            await self.container.templateRepository.getTemplate(
                id: self.arguments.templateId,
                usExaminationTypesById: self.container.usExaminationTypesById
            )!
        } onMainSuccess: { template in
            self.usExaminationType = self.container.usExaminationTypesById[template.usExaminationType.id]
                ?? self.container.usExaminationTypeDefault
            self.templateController.text = template.content
        }
    }

    @Published var focus: Focus?
    @Published var usExaminationType: USExaminationType
    @NestedObservableObject var templateController = DTextFieldController()

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

        unfocus()

        let content = templateController.text
        let template = USExaminationTemplate(
            id: arguments.templateId,
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

    func onTapDelete(
        ultrasoundViewModel: UltrasoundViewModel
    ) {
        ultrasoundViewModel.deleteTemplate(
            id: arguments.templateId
        )
        messager.show(
            type: .success,
            title: .templateDeletedSuccessTitle,
            description: .templateDeletedSuccessDescription
        )
        router.pop()
    }
}

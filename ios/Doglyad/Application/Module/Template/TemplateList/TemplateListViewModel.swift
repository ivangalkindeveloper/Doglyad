import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class TemplateListViewModel {
    private let container: DependencyContainer
    private let router: DRouter

    init(
        container: DependencyContainer,
        router: DRouter
    ) {
        self.container = container
        self.router = router
        load()
    }

    var templates: [USExaminationTemplate] = []

    func load() {
        templates = container.templateRepository.getTemplates(
            usExaminationTypesById: container.usExaminationTypesById
        )
    }

    func onTapBack() {
        router.pop()
    }

    func onTapAdd() {
        router.push(
            route: RouteScreen(
                type: .templateAdd
            )
        )
    }

    func onTapTemplate(
        _ template: USExaminationTemplate
    ) {
        router.push(
            route: RouteScreen(
                type: .templateEdit,
                arguments: TemplateEditScreenArguments(
                    templateId: template.id
                )
            )
        )
    }
}

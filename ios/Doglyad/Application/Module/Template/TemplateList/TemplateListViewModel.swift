import DoglyadNetwork
import Foundation
import Handler
import Router
import SwiftUI

@MainActor
final class TemplateListViewModel: BaseViewModel {
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

    override func onInit() {
        handle {
            await self.container.templateRepository.getTemplates(
                usExaminationTypesById: self.container.usExaminationTypesById
            )
        } onMainSuccess: { templates in
            self.templates = templates
        }
    }

    @Published var templates: [USExaminationTemplate] = []

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

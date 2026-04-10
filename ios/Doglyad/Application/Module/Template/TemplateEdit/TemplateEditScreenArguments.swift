import Router

final class TemplateEditScreenArguments: RouteArgumentsProtocol {
    let templateId: String

    init(templateId: String) {
        self.templateId = templateId
    }
}

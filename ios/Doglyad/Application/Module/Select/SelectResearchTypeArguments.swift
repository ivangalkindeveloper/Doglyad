import Router

final class SelectResearchTypeArguments: RouteArgumentsProtocol {
    let currentValue: ResearchType?
    let onSelected: (ResearchType) -> Void

    init(
        currentValue: ResearchType? = nil,
        onSelected: @escaping (ResearchType) -> Void
    ) {
        self.currentValue = currentValue
        self.onSelected = onSelected
    }
}

import Foundation

final class SelectResearchTypeViewModel: ObservableObject {
    var researchTypes: [ResearchType] = [
        .thyroidGland,
    ]
    
    func onPressedType(
        arguments: SelectResearchTypeScreenArguments?,
        type: ResearchType,
    ) -> Void {
        arguments?.onSelected(type)
    }
}

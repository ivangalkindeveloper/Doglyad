import DoglyadUI
import Foundation
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: ObservableObject {
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let messager: DMessager
    private let router: DRouter

    init(
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        messager: DMessager,
        router: DRouter,
        initialConclusion: ResearchConclusion
    ) {
        self.diagnosticRepository = diagnosticRepository
        self.messager = messager
        self.router = router
        _conclusion = .init(initialValue: initialConclusion)
    }

    @Published var conclusion: ResearchConclusion

    func onTapBack() {
        router.pop()
    }

    var conclusionShareContent: String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(conclusion),
              let string = String(data: data, encoding: .utf8)
        else { return "" }
        return string
    }

    func onTapCopy(
        conclusion: ResearchModelConclusion
    ) {
        UIPasteboard.general.string = conclusion.response
        messager.show(
            type: .success,
            title: .conclusionModelResponseCopyMessageTitle,
            description: .conclusionModelResponseCopyMessageDescription
        )
    }

    func onTapRepeatScan(
        proxy _: ScrollViewProxy
    ) {
        // TODO
    }
}

import DoglyadUI
import DoglyadNetwork
import Foundation
import Handler
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: Handler<DHttpApiError, DHttpConnectionError>, ObservableObject {
    static let actualModelConclusionCardScrollId = "actualModelConclusionCard"

    private let modelRepository: ModelRepositoryProtocol
    private let diagnosticRepository: DiagnosticsRepositoryProtocol
    private let messager: DMessager
    private let router: DRouter

    init(
        modelRepository: ModelRepositoryProtocol,
        diagnosticRepository: DiagnosticsRepositoryProtocol,
        messager: DMessager,
        router: DRouter,
        initialConclusion: ResearchConclusion
    ) {
        self.modelRepository = modelRepository
        self.diagnosticRepository = diagnosticRepository
        self.messager = messager
        self.router = router
        _conclusion = .init(initialValue: initialConclusion)
    }

    @Published var conclusion: ResearchConclusion
    @Published var isLoading = false
    
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
        proxy: ScrollViewProxy
    ) {
        let neuralModelSettings = self.modelRepository.getNeuralModelSettings()
        let request = ResearchRequest(
            neuralModelSettings: neuralModelSettings,
            researchData: self.conclusion.researchData
        )
        
        handle {
            self.isLoading = true
            return try await self.diagnosticRepository.generateConclusion(
                request: request,
                locale: Locale.current
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { modelConclusion in
            let updatedConclusion = ResearchConclusion(
                id: self.conclusion.id,
                date: self.conclusion.date,
                neuralModelSettings: neuralModelSettings,
                researchData: self.conclusion.researchData,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: [self.conclusion.actualModelConclusion] + self.conclusion.previosModelConclusions
            )
            
            self.diagnosticRepository.updateConclusion(
                conclusion: updatedConclusion
            )
            
            self.conclusion = updatedConclusion
            withAnimation {
                proxy.scrollTo(Self.actualModelConclusionCardScrollId, anchor: .top)
            }
            self.messager.show(
                type: .success,
                title: .conclusionModelResponseUpdatedMessageTitle,
                description: .conclusionModelResponseUpdatedMessageDescription
            )
        } onUnknownError: { _ in
            self.messager.showUnknownError()
        }
    }
}

import DoglyadNetwork
import DoglyadUI
import Foundation
import Handler
import SwiftUI
import UIKit

@MainActor
final class ConclusionViewModel: Handler<DHttpApiError, DHttpConnectionError>, ObservableObject {
    static let actualModelConclusionCardScrollId = "actualModelConclusionCard"

    private let modelRepository: ModelRepositoryProtocol
    private let usExaminationRepository: USExaminationRepositoryProtocol
    private let messager: DMessager
    private let router: DRouter

    init(
        modelRepository: ModelRepositoryProtocol,
        usExaminationRepository: USExaminationRepositoryProtocol,
        messager: DMessager,
        router: DRouter,
        initialConclusion: USExaminationConclusion
    ) {
        self.modelRepository = modelRepository
        self.usExaminationRepository = usExaminationRepository
        self.messager = messager
        self.router = router
        _conclusion = .init(initialValue: initialConclusion)
    }

    @Published var conclusion: USExaminationConclusion
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
        conclusion: USExaminationModelConclusion
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
        let neuralModelSettings = modelRepository.getNeuralModelSettings()
        let request = USExaminationRequest(
            neuralModelSettings: neuralModelSettings,
            examinationData: conclusion.examinationData
        )

        handle {
            self.isLoading = true
            return try await self.usExaminationRepository.generateConclusion(
                request: request,
                locale: Locale.current
            )
        } onDefer: {
            self.isLoading = false
        } onMainSuccess: { modelConclusion in
            let updatedConclusion = USExaminationConclusion(
                id: self.conclusion.id,
                date: self.conclusion.date,
                neuralModelSettings: neuralModelSettings,
                examinationData: self.conclusion.examinationData,
                actualModelConclusion: modelConclusion,
                previosModelConclusions: [self.conclusion.actualModelConclusion] + self.conclusion.previosModelConclusions
            )

            self.usExaminationRepository.updateConclusion(
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

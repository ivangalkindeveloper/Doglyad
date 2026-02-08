import DoglyadUI
import Foundation
import NestedObservableObject
import Router
import SwiftUI

@MainActor
final class NeuralModelViewModel: ObservableObject {
    enum Focus: Hashable {
        case template
        case length
    }

    private let modelRepository: ModelRepositoryProtocol
    private let messanger: DMessager
    private let router: DRouter

    init(
        modelRepository: ModelRepositoryProtocol,
        messanger: DMessager,
        router: DRouter
    ) {
        self.modelRepository = modelRepository
        self.messanger = messanger
        self.router = router
        onInit()
    }

    @Published var focus: Focus? = nil
    @NestedObservableObject var templateController = DTextFieldController()
    @NestedObservableObject var responseLengthController = DTextFieldController()

    func onInit() {
        let settings = modelRepository.getNeuralModelSettings()
        templateController.text = settings.template ?? ""
        responseLengthController.text = settings.responseLength.map(String.init) ?? ""
    }

    func unfocus() {
        focus = nil
    }

    func onSubmit() {
        switch focus {
        case .template:
            focus = .length
        case .length, .none:
            focus = nil
        }
    }

    func onTapBack() {
        router.pop()
    }

    func onTapSave() {
        let template = templateController.text.isEmpty ? nil : templateController.text
        let responseLength = Int(responseLengthController.text)
        modelRepository.setNeuralModelSettings(
            settings: NeuralModelSettings(
                template: template,
                responseLength: responseLength
            )
        )
        messanger.show(
            type: .success,
            title: .neuralModelSettingsSavedSuccessDescription
        )
        router.pop()
    }
}

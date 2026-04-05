import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class NeuralModelViewModel {
    enum Focus: Hashable {
        case template
        case length
    }

    private let messager: DMessager
    private let router: DRouter
    private let onSave: (USExaminationNeuralModel, String?, Int?) -> Void

    init(
        initialNeuralModel: USExaminationNeuralModel,
        initialTemplate: String?,
        initialResponseLength: Int?,
        messager: DMessager,
        router: DRouter,
        onSave: @escaping (USExaminationNeuralModel, String?, Int?) -> Void
    ) {
        self.usExaminationNeuralModel = initialNeuralModel
        self.messager = messager
        self.router = router
        self.onSave = onSave
        templateController.text = initialTemplate ?? ""
        responseLengthController.text = initialResponseLength.map(String.init) ?? ""
    }

    var usExaminationNeuralModel: USExaminationNeuralModel
    var focus: Focus? = nil
    var templateController = DTextFieldController()
    var responseLengthController = DTextFieldController()

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

    func onTapNeuralModel() {
        router.push(
            route: RouteSheet(
                type: .selectNeuralModel,
                arguments: SelectNeuralModelArguments(
                    currentValue: usExaminationNeuralModel,
                    onSelected: { [weak self] model in
                        guard let self = self else { return }
                        guard self.usExaminationNeuralModel != model else { return }

                        self.usExaminationNeuralModel = model
                        onSave(model, nil, nil)
                    }
                )
            )
        )
    }

    func onTapSave() {
        let template = templateController.text.isEmpty ? nil : templateController.text
        let responseLength = Int(responseLengthController.text)
        onSave(usExaminationNeuralModel, template, responseLength)
        messager.show(
            type: .success,
            title: .neuralModelSettingsSavedSuccessMessageTitle,
            description: .neuralModelSettingsSavedSuccessMessageDescription
        )
        router.pop()
    }
}

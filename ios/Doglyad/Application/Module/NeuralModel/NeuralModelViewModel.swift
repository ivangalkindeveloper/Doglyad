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

    private let container: DependencyContainer
    private let messager: DMessager
    private let router: DRouter

    init(
        container: DependencyContainer,
        messager: DMessager,
        router: DRouter
    ) {
        self.container = container
        usExaminationNeuralModel = container.usExaminationNeuralModelDefault
        self.messager = messager
        self.router = router
        onInit()
    }

    @Published var usExaminationNeuralModel: USExaminationNeuralModel
    @Published var focus: Focus? = nil
    @NestedObservableObject var templateController = DTextFieldController()
    @NestedObservableObject var responseLengthController = DTextFieldController()

    func onInit() {
        let settings = container.modelRepository.getNeuralModelSettings()
        if let selectedModelId = settings.selectedNeuralModelId,
           let selectedModel = container.usExaminationNeuralModelsById[selectedModelId]
        {
            usExaminationNeuralModel = selectedModel
        }

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
                        self.container.modelRepository.setSelectedUSExaminationNeuralModelId(
                            id: model.id
                        )
                    }
                )
            )
        )
    }

    func onTapSave() {
        let template = templateController.text.isEmpty ? nil : templateController.text
        let responseLength = Int(responseLengthController.text)
        container.modelRepository.setNeuralModelSettings(
            settings: NeuralModelSettings(
                selectedNeuralModelId: usExaminationNeuralModel.id,
                template: template,
                responseLength: responseLength
            )
        )
        messager.show(
            type: .success,
            title: .neuralModelSettingsSavedSuccessMessageTitle,
            description: .neuralModelSettingsSavedSuccessMessageDescription
        )
        router.pop()
    }
}

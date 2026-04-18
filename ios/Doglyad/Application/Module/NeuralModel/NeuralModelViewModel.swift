import DoglyadUI
import Foundation
import Router
import SwiftUI

@MainActor
@Observable
final class NeuralModelViewModel {
    enum Focus: Hashable {
        case temperature
        case length
    }

    private let messager: DMessager
    private let router: DRouter
    private let onNeuralModelSelected: (USExaminationNeuralModel) -> Void
    private let onSettingsSaved: (Double?, Int?) -> Void

    init(
        initialNeuralModel: USExaminationNeuralModel,
        initialTemperature: Double,
        initialResponseLength: Int,
        messager: DMessager,
        router: DRouter,
        onNeuralModelSelected: @escaping (USExaminationNeuralModel) -> Void,
        onSettingsSaved: @escaping (Double?, Int?) -> Void
    ) {
        usExaminationNeuralModel = initialNeuralModel
        self.messager = messager
        self.router = router
        self.onNeuralModelSelected = onNeuralModelSelected
        self.onSettingsSaved = onSettingsSaved
        temperatureController.text = String(initialTemperature)
        responseLengthController.text = String(initialResponseLength)
    }

    var usExaminationNeuralModel: USExaminationNeuralModel
    var focus: Focus?
    var temperatureController = DTextFieldController()
    var responseLengthController = DTextFieldController()

    func unfocus() {
        focus = nil
    }

    func onSubmit() {
        switch focus {
        case .temperature:
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
                        self.onNeuralModelSelected(model)
                    }
                )
            )
        )
    }

    func onTapSave() {
        onSettingsSaved(
            Double(temperatureController.text),
            Int(responseLengthController.text)
        )
        messager.show(
            type: .success,
            title: .neuralModelSettingsSavedSuccessMessageTitle,
            description: .neuralModelSettingsSavedSuccessMessageDescription
        )
        router.pop()
    }
}

import SwiftUI
import DoglyadUI

final class ThyroidGlandScanStrategy: ScanStrategyProtocol {
    typealias VM = ThyroidGlandStrategyViewModel
    typealias V = ThyroidGlandStrategyView
    
    let viewModel: ThyroidGlandStrategyViewModel
    let view: ThyroidGlandStrategyView
    
    init() {
        self.viewModel = ThyroidGlandStrategyViewModel()
        self.view = ThyroidGlandStrategyView(
            viewModel: viewModel,
        )
    }
}

final class ThyroidGlandStrategyViewModel: ScanStrategyViewModelProtocol {
    typealias T = ThyroidGlandStrategyData
    
    @NestedObservableObject var patientHeightController = DTextFieldController()
    @NestedObservableObject var patientWeightController = DTextFieldController()
    @NestedObservableObject var thyroidGlandIsthmusController = DTextFieldController()
    @NestedObservableObject var thyroidGlandRightLobeController = DTextFieldController()
    @NestedObservableObject var thyroidGlandLeftLobeController = DTextFieldController()
    
    func validate() -> Void {}
    
    func getData() -> ThyroidGlandStrategyData {
        ThyroidGlandStrategyData(
            patientHeight: Double(patientHeightController.text),
            patientWeight: Double(patientWeightController.text),
            thyroidGlandIsthmus: Double(thyroidGlandIsthmusController.text),
            thyroidGlandRightLobe: Double(thyroidGlandRightLobeController.text),
            thyroidGlandLeftLobe: Double(thyroidGlandLeftLobeController.text),
        )
    }
}

struct ThyroidGlandStrategyView: ScanStrategyViewProtocol {
    typealias VM = ThyroidGlandStrategyViewModel
    
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @StateObject var viewModel: ThyroidGlandStrategyViewModel
    
    init(
        viewModel: ThyroidGlandStrategyViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            DTextField<EmptyView>(
                title: .fieldPatientHeight,
                placeholder: .fieldPatientHeightPlaceholder,
                controller: viewModel.patientHeightController
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView>(
                title: .fieldPatientWeight,
                placeholder: .fieldPatientWeightPlaceholder,
                controller: viewModel.patientWeightController
            )
            .padding(.bottom, size.s8)
            
        }
    }
}

struct ThyroidGlandStrategyData: ScanStrategyDataProtocol {
    let patientHeight: Double? // Вес пациента
    let patientWeight: Double? // Рост пациента
    let thyroidGlandIsthmus: Double? // Высота перешеек
    let thyroidGlandRightLobe: Double? // Правая доля
    let thyroidGlandLeftLobe: Double? // Левая доля
}

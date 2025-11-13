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
    
    @NestedObservableObject var isthmusThicknessController = DTextFieldController()
    
    @NestedObservableObject var rightLobeWidthController = DTextFieldController()
    @NestedObservableObject var rightLobeThicknessController = DTextFieldController()
    @NestedObservableObject var rightLobeLengthController = DTextFieldController()
    
    @NestedObservableObject var leftLobeWidthController = DTextFieldController()
    @NestedObservableObject var leftLobeThicknessController = DTextFieldController()
    @NestedObservableObject var leftLobeLengthController = DTextFieldController()

    
    func validate() -> Void {}
    
    func fillFromSpeech(
        data: [String : String]
    ) {
        
    }
    
    func getData() -> ThyroidGlandStrategyData {
        ThyroidGlandStrategyData(
            patientHeight: Double(patientHeightController.text),
            patientWeight: Double(patientWeightController.text),
            
            isthmusThickness: Double(isthmusThicknessController.text),
            
            rightLobeWidth: Double(rightLobeWidthController.text),
            rightLobeThickness: Double(rightLobeThicknessController.text),
            rightLobeLength: Double(rightLobeLengthController.text),
            
            leftLobeWidth: Double(leftLobeWidthController.text),
            leftLobeThickness: Double(leftLobeThicknessController.text),
            leftLobeLength: Double(leftLobeLengthController.text),
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
            // MARK: - Patient Height
            DTextField<EmptyView>(
                title: .fieldPatientHeightCM,
                placeholder: .fieldPatientHeightCMPlaceholder,
                controller: viewModel.patientHeightController
            )
            .padding(.bottom, size.s8)
            
            // MARK: - Patient Weight
            DTextField<EmptyView>(
                title: .fieldPatientWeightKG,
                placeholder: .fieldPatientWeightKGPlaceholder,
                controller: viewModel.patientWeightController
            )
            .padding(.bottom, size.s8)
            
            // MARK: - Isthmus
            DText(.scanThyroidGlandIsthmusLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .vertical], size.s8)
            DTextField<EmptyView>(
                title: .fieldThicknessMM,
                placeholder: .fieldValuePlaceholder,
                controller: viewModel.isthmusThicknessController
            )
            .padding(.bottom, size.s8)
            
            // MARK: - Right Lobe
            DText(.scanThyroidGlandRightLobeLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .vertical], size.s8)
            HStack(
                spacing: size.s8,
            ) {
                DTextField<EmptyView>(
                    title: .fieldWidthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeWidthController
                )
                DTextField<EmptyView>(
                    title: .fieldThicknessMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeThicknessController
                )
                DTextField<EmptyView>(
                    title: .fieldLengthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeLengthController
                )
            }
            .padding(.bottom, size.s8)
            
            // MARK: - Left Lobe
            DText(.scanThyroidGlandLeftLobeLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .vertical], size.s8)
            HStack(
                spacing: size.s8,
            ) {
                DTextField<EmptyView>(
                    title: .fieldWidthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeWidthController
                )
                DTextField<EmptyView>(
                    title: .fieldThicknessMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeThicknessController
                )
                DTextField<EmptyView>(
                    title: .fieldLengthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeLengthController
                )
            }
            .padding(.bottom, size.s8)
        }
    }
}

struct ThyroidGlandStrategyData: ScanStrategyDataProtocol {
    let patientHeight: Double? // Вес пациента
    let patientWeight: Double? // Рост пациента
    let isthmusThickness: Double? // Перешеек
    let rightLobeWidth: Double? // Правая доля
    let rightLobeThickness: Double? // Правая доля
    let rightLobeLength: Double? // Правая доля
    let leftLobeWidth: Double? // Левая доля
    let leftLobeThickness: Double? // Левая доля
    let leftLobeLength: Double? // Левая доля
}

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
    
    @NestedObservableObject var rightLobeHeightController = DTextFieldController()
    @NestedObservableObject var rightLobeWidthController = DTextFieldController()
    @NestedObservableObject var rightLobeDepthController = DTextFieldController()
    
    @NestedObservableObject var leftLobeHeightController = DTextFieldController()
    @NestedObservableObject var leftLobeWidthController = DTextFieldController()
    @NestedObservableObject var leftLobeDepthController = DTextFieldController()
    
    @NestedObservableObject var isthmusDepthController = DTextFieldController()
    
    func validate() -> Void {}
    
    func fillFromSpeech(
        data: [String : String]
    ) {
        
    }
    
    func getData() -> ThyroidGlandStrategyData {
        ThyroidGlandStrategyData(
            patientHeight: Double(patientHeightController.text),
            patientWeight: Double(patientWeightController.text),
            rightLobe: DimensionsData(
                height: Double(rightLobeHeightController.text),
                width: Double(rightLobeWidthController.text),
                depth: Double(rightLobeDepthController.text),
            ),
            leftLobe: DimensionsData(
                height: Double(leftLobeHeightController.text),
                width: Double(leftLobeWidthController.text),
                depth: Double(leftLobeDepthController.text),
            ),
            isthmus: DimensionsData(
                height: nil,
                width: nil,
                depth: Double(isthmusDepthController.text),
            ),
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
                title: .fieldPatientHeightCM,
                placeholder: .fieldPatientHeightCMPlaceholder,
                controller: viewModel.patientHeightController
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView>(
                title: .fieldPatientWeightKG,
                placeholder: .fieldPatientWeightKGPlaceholder,
                controller: viewModel.patientWeightController
            )
            .padding(.bottom, size.s8)
            
            DText(.scanThyroidGlandRightLobeLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .leading], size.s8)
            HStack(
                spacing: size.s16,
            ) {
                DTextField<EmptyView>(
                    title: .fieldHeightMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeHeightController
                )
                DTextField<EmptyView>(
                    title: .fieldWidthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeWidthController
                )
                DTextField<EmptyView>(
                    title: .fieldDepthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.rightLobeDepthController
                )
            }
            .padding(.bottom, size.s8)
            
            DText(.scanThyroidGlandLeftLobeLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .leading], size.s8)
            HStack(
                spacing: size.s16,
            ) {
                DTextField<EmptyView>(
                    title: .fieldHeightMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeHeightController
                )
                DTextField<EmptyView>(
                    title: .fieldWidthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeWidthController
                )
                DTextField<EmptyView>(
                    title: .fieldDepthMM,
                    placeholder: .fieldValuePlaceholder,
                    controller: viewModel.leftLobeDepthController
                )
            }
            .padding(.bottom, size.s8)
            
            DText(.scanThyroidGlandIsthmusLabel)
                .dStyle(
                    font: typography.linkSmall,
                )
                .padding([.bottom, .leading], size.s8)
            DTextField<EmptyView>(
                title: .fieldDepthMM,
                placeholder: .fieldValuePlaceholder,
                controller: viewModel.isthmusDepthController
            )
        }
    }
}

struct ThyroidGlandStrategyData: ScanStrategyDataProtocol {
    let patientHeight: Double? // Вес пациента
    let patientWeight: Double? // Рост пациента
    let rightLobe: DimensionsData? // Правая доля
    let leftLobe: DimensionsData? // Левая доля
    let isthmus: DimensionsData? // Перешеек
}

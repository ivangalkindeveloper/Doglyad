import SwiftUI
import DoglyadUI
import BottomSheet

struct ScanSheetView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            DInput<EmptyView>(
                placeholder: .fieldPatientName,
                controller: viewModel.patientNameController
            )
            .padding(.top, size.s32)
            .padding(.bottom, size.s16)
            
            DSegment<PatientGender>(
                currentValue: viewModel.patientGender,
                items: [
                    DSegmentItem<PatientGender>(
                        value: .male,
                        title: .scanGenderMaleLabel
                    ) {
                        viewModel.onPressedGender(value: .male)
                    },
                    DSegmentItem<PatientGender>(
                        value: .female,
                        title: .scanGenderFemaleLabel
                    ) {
                        viewModel.onPressedGender(value: .female)
                    }
                ]
            )
            .padding(.bottom, size.s16)
            
            HStack(
                spacing: .zero
            ) {
                Spacer()
                DText(.scanPatientDateOfBirthLabel)
                    .dStyle(
                        font: typography.textMedium
                    )
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.patientDateOfBirth,
                    displayedComponents: .date
                )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(color.primaryDefault)
            }
            .padding(.bottom, size.s16)
            
            // Компоненты
            
            DInput<EmptyView>(
                placeholder: .fieldPatientComplaint,
                controller: viewModel.patientComplaintController
            )
            .padding(.bottom, size.s32)
            
            DButton(
                title: .buttonScan,
                action: viewModel.onPressedScan
            )
            .dStyle(.primaryButton)
            .padding(.bottom, size.s16)
        }
        .padding([.horizontal], size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

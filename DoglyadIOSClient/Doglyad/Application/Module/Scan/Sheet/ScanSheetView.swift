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
            DTextField<EmptyView>(
                title: .fieldPatientName,
                placeholder: .fieldPatientNamePlaceholder,
                controller: viewModel.patientNameController
            )
            .padding(.vertical, size.s16)
            
            DSegment<PatientGender>(
                currentValue: viewModel.patientGender,
                items: [
                    DSegmentItem<PatientGender>(
                        value: .male,
                        title: .scanGenderMaleLabel
                    ) {
                        viewModel.onPressedPatientGender(value: .male)
                    },
                    DSegmentItem<PatientGender>(
                        value: .female,
                        title: .scanGenderFemaleLabel
                    ) {
                        viewModel.onPressedPatientGender(value: .female)
                    }
                ]
            )
            .padding(.bottom, size.s16)
            
            DDateOfBirthCard(
                title: .scanDateOfBirthLabel,
                ageLabel: .scanDateOfBirthAgeLabel,
                date: viewModel.patientDateOfBirth,
            ) {
                //
            }
            .padding(.bottom, size.s16)
            
            // Компоненты
            
            DTextField<EmptyView>(
                title: .fieldPatientComplaint,
                placeholder: .fieldPatientComplaintPlaceholder,
                controller: viewModel.patientComplaintController
            )
            .padding(.bottom, size.s32)
        }
        .padding([.horizontal], size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

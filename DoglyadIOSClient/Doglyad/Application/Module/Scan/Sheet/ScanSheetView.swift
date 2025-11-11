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
        ScrollView(
            showsIndicators: false
        ) {
            DTextField<EmptyView>(
                title: .fieldPatientName,
                placeholder: .fieldPatientNamePlaceholder,
                controller: viewModel.patientNameController
            )
            .padding(.vertical, size.s8)
            
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
            .padding(.bottom, size.s8)
            
            DDateOfBirthCard(
                title: .scanDateOfBirthLabel,
                ageLabel: .scanDateOfBirthAgeLabel,
                date: viewModel.patientDateOfBirth,
            ) {
                viewModel.onPressedPatientDateOfBirth()
            }
            .padding(.bottom, size.s16)
            
            AnyView(viewModel.scanStrategy.view)
                .padding(.bottom, size.s16)
            
            DTextField<EmptyView>(
                title: .fieldPatientComplaint,
                placeholder: .fieldPatientComplaintPlaceholder,
                controller: viewModel.patientComplaintController
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView>(
                title: .fieldAdditionalMedicalData,
                placeholder: .fieldAdditionalMedicalDataPlaceholder,
                controller: viewModel.additionalMedicalDataController
            )
            .padding(.bottom, size.s128)
        }
        .padding(.horizontal, size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

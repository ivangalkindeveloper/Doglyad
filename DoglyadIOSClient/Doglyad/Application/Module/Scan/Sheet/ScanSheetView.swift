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
            DTextField<EmptyView, EmptyView>(
                title: .scanPatientName,
                placeholder: .scanPatientNamePlaceholder,
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
                        viewModel.onTapPatientGender(value: .male)
                    },
                    DSegmentItem<PatientGender>(
                        value: .female,
                        title: .scanGenderFemaleLabel
                    ) {
                        viewModel.onTapPatientGender(value: .female)
                    }
                ]
            )
            .padding(.bottom, size.s8)
            
            DateOfBirthCard(
                date: viewModel.patientDateOfBirth,
                action: viewModel.onTapPatientDateOfBirth
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView, EmptyView>(
                title: .scanResearchDescription,
                placeholder: .scanResearchDescriptionPlaceholder,
                controller: viewModel.researchDataController
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView, EmptyView>(
                title: .scanPatientComplaint,
                placeholder: .scanPatientComplaintPlaceholder,
                controller: viewModel.patientComplaintController
            )
            .padding(.bottom, size.s8)
            
            DTextField<EmptyView, EmptyView>(
                title: .scanAdditionalMedicalData,
                placeholder: .scanAdditionalMedicalDataPlaceholder,
                controller: viewModel.additionalMedicalDataController
            )
            .padding(.bottom, size.s128 * 2)
        }
        .padding(.horizontal, size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

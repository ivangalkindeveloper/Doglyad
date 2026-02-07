import BottomSheet
import DoglyadUI
import SwiftUI

struct ScanSheetBodyView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ScanViewModel
    let focus: FocusState<ScanViewModel.Focus?>.Binding

    var body: some View {
        ScrollView(
            showsIndicators: false
        ) {
            VStack(
                spacing: .zero
            ) {
                DTextField(
                    controller: viewModel.patientNameController,
                    focus: DTextFieldFocus(
                        value: .patientName,
                        state: focus
                    ),
                    title: .scanPatientNameLabel,
                    placeholder: .scanPatientNamePlaceholder,
                    keyboardType: .default,
                    sumbitLabel: .next
                )
                .padding(.vertical, size.s4)

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
                        },
                    ]
                )
                .padding(.bottom, size.s4)

                DateOfBirthCard(
                    date: viewModel.patientDateOfBirth,
                    action: viewModel.onTapPatientDateOfBirth
                )
                .padding(.bottom, size.s4)

                DTextField(
                    controller: viewModel.patientHeightCMController,
                    focus: DTextFieldFocus(
                        value: .patientHeightCM,
                        state: focus
                    ),
                    title: .scanPatientHeightCMLabel,
                    placeholder: .scanNumberPlaceholder,
                    keyboardType: .decimalPad,
                    sumbitLabel: .next
                )
                .padding(.bottom, size.s4)

                DTextField(
                    controller: viewModel.patientWeightKGController,
                    focus: DTextFieldFocus(
                        value: .patientWeightKG,
                        state: focus
                    ),
                    title: .scanPatientWeightKGLabel,
                    placeholder: .scanNumberPlaceholder,
                    keyboardType: .decimalPad,
                    sumbitLabel: .next
                )
                .padding(.bottom, size.s4)

                DTextField(
                    controller: viewModel.patientComplaintController,
                    focus: DTextFieldFocus(
                        value: .patientComplaint,
                        state: focus
                    ),
                    title: .scanPatientComplaintLabel,
                    placeholder: .scanPatientComplaintPlaceholder,
                    keyboardType: .default,
                    sumbitLabel: .next
                )
                .padding(.bottom, size.s4)

                DTextField(
                    controller: viewModel.researchDescriptionController,
                    focus: DTextFieldFocus(
                        value: .researchDescription,
                        state: focus
                    ),
                    title: .scanResearchDescriptionLabel,
                    placeholder: .scanResearchDescriptionPlaceholder,
                    keyboardType: .default,
                    sumbitLabel: .next
                )
                .padding(.bottom, size.s4)

                DTextField(
                    controller: viewModel.additionalDataController,
                    focus: DTextFieldFocus(
                        value: .additionalData,
                        state: focus
                    ),
                    title: .scanAdditionalDataLabel,
                    placeholder: .scanAdditionalDataPlaceholder,
                    keyboardType: .default,
                    sumbitLabel: .done
                )
            }
            .padding(.bottom, size.screenHeight / 4)
        }
        .padding(.horizontal, size.s16)
    }
}

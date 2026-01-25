import SwiftUI
import DoglyadUI
import BottomSheet

struct ScanSheetBodyView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        ScrollView(
            showsIndicators: false
        ) {
            VStack(
                spacing: .zero,
            ) {
                DTextField<EmptyView, EmptyView>(
                    title: .scanPatientNameLabel,
                    placeholder: .scanPatientNamePlaceholder,
                    controller: viewModel.patientNameController,
                    keyboardType: .default,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
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
                        }
                    ]
                )
                .padding(.bottom, size.s4)
                
                DateOfBirthCard(
                    date: viewModel.patientDateOfBirth,
                    action: viewModel.onTapPatientDateOfBirth
                )
                .padding(.bottom, size.s4)
                
                DTextField<EmptyView, EmptyView>(
                    title: .scanPatientHeightCMLabel,
                    placeholder: .scanNumberPlaceholder,
                    controller: viewModel.patientHeightCMController,
                    keyboardType: .decimalPad,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
                .padding(.bottom, size.s4)
                
                DTextField<EmptyView, EmptyView>(
                    title: .scanPatientWeightKGLabel,
                    placeholder: .scanNumberPlaceholder,
                    controller: viewModel.patientWeightKGController,
                    keyboardType: .decimalPad,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
                .padding(.bottom, size.s4)
                
                DTextField<EmptyView, EmptyView>(
                    title: .scanPatientComplaintLabel,
                    placeholder: .scanPatientComplaintPlaceholder,
                    controller: viewModel.patientComplaintController,
                    keyboardType: .default,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
                .padding(.bottom, size.s4)
                
                DTextField<EmptyView, EmptyView>(
                    title: .scanResearchDescriptionLabel,
                    placeholder: .scanResearchDescriptionPlaceholder,
                    controller: viewModel.researchDescriptionController,
                    keyboardType: .default,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
                .padding(.bottom, size.s4)
                
                DTextField<EmptyView, EmptyView>(
                    title: .scanAdditionalDataLabel,
                    placeholder: .scanAdditionalDataPlaceholder,
                    controller: viewModel.additionalDataController,
                    keyboardType: .default,
                    sumbitLabel: .done
                )
                .onSubmit {
                    viewModel.unfocus()
                }
            }
            .padding(.bottom, size.s128 * 3)
        }
        .padding(.horizontal, size.s16)
        .onTapGesture {
            viewModel.unfocus()
        }
    }
}

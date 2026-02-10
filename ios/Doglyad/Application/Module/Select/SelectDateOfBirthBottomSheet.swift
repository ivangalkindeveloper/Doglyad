import DoglyadUI
import Router
import SwiftUI

struct SelectDateOfBirthBottomSheet: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    let arguments: SelectDateOfBirthArguments?
    @State private var date: Date
    private let fromDate: Date
    private let toDate: Date = .init()

    init(
        arguments: SelectDateOfBirthArguments?
    ) {
        self.arguments = arguments
        date = arguments?.currentValue ?? Date()
        fromDate = Calendar.current.date(byAdding: .year, value: -100, to: toDate)!
    }

    var body: some View {
        DBottomSheet(
            title: .selectDateOfBirthTitle,
            fraction: 0.5
        ) {
            VStack(
                spacing: .zero
            ) {
                DatePicker(
                    .selectDateOfBirthTitle,
                    selection: Binding<Date>(
                        get: { date },
                        set: { date = $0 }
                    ),
                    in: fromDate ... toDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
                .colorScheme(.light)
                .padding(.bottom, size.s16)

                Spacer()
            }
            .padding(size.s16)
        } bottom: {
            DButton(
                title: .buttonSelect
            ) {
                router.dismissSheet()
                arguments?.onSelected(date)
            }
            .dStyle(.primaryButton)
            .padding(size.s16)
        }
    }
}

#Preview {
    SelectDateOfBirthBottomSheet(
        arguments: nil
    )
    .previewable()
}

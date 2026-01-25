import SwiftUI
import Router
import DoglyadUI

final class SelectDateOfBirthArguments: RouteArgumentsProtocol {
    let currentValue: Date?
    let onSelected: (Date) -> Void
    
    init(
        currentValue: Date? = nil,
        onSelected: @escaping (Date) -> Void
    ) {
        self.currentValue = currentValue
        self.onSelected = onSelected
    }
}

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
    private let toDate: Date = Date()
    
    init(
        arguments: SelectDateOfBirthArguments?
    ) {
        self.arguments = arguments
        self.date = arguments?.currentValue ?? Date()
        self.fromDate =  Calendar.current.date(byAdding: .year, value: -100, to: toDate)!
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
                    in: fromDate...toDate,
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

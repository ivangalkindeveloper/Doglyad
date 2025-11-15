import Foundation
import SwiftUI
import DoglyadUI

public struct DDateOfBirthCard: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    private let title: LocalizedStringResource = .scanDateOfBirthLabel
    private let ageLabel: LocalizedStringResource = .scanDateOfBirthAgeLabel
    
    let date: Date
    let action: () -> Void

    public init(
        date: Date,
        action: @escaping () -> Void
    ) {
        self.date = date
        self.action = action
    }

    public var body: some View {
        Button(
            action: action
        ) {
            HStack(
                spacing: 0
            ) {
                DText("\(title) \(date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits).locale(Locale(identifier: "ru_RU"))))"
                )
                    .dStyle(
                        font: typography.linkSmall,
                    )
                    .padding(.trailing , size.s8)
                
                DText("(\(ageCount()) \(ageLabel))")
                    .dStyle(
                        font: typography.textXSmall,
                        color: color.grayscalePlaceholder
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DButtonStyle(.chip))
    }
}

private extension DDateOfBirthCard {
    func ageCount() -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: date, to: Date()).year!
    }
}

#Preview {
    @Previewable @State var date = {
        let dateString = "06.12.2000"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.date(from: dateString)!
    }()

    DThemeWrapperView {
        DDateOfBirthCard(
            date: date,
            action: {}
        )
        .padding()
    }
}

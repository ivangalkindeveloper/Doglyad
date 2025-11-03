import SwiftUI

struct BirthDatePickerView: View {
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
    
    var age: Int {
        let diff = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        return diff.year ?? 0
    }
    
    var body: some View {
        VStack {
            Text("\(age)")
                .font(.headline)
            
            DatePicker("", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.purple)
                .foregroundStyle(.cyan)
                .foregroundColor(.orange)
            
//            DatePicker("Дата", selection: $birthDate, displayedComponents: .date)
//                .datePickerStyle(.compact)
//                .labelsHidden()
//                .tint(.orange) // влияет на кнопки и выделения
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color(.red))
//                        .shadow(radius: 3)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.red.opacity(0.7), lineWidth: 1)
//                )
        }
        .padding()
    }
}

#Preview {
    BirthDatePickerView()
}

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


struct BasicTextField: View {
    @State private var text = ""

    var body: some View {
        TextField("Введите текст", text: $text)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}

struct CustomPlainTextField: View {
    @State private var text = ""

    var body: some View {
        TextField("Введите имя", text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}


struct TextFieldWithIcon: View {
    @State private var text = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Поиск...", text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}


struct PasswordField: View {
    @State private var password = ""

    var body: some View {
        SecureField("Пароль", text: $password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct FloatingLabelTextField: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            Text("Имя")
                .foregroundColor(isFocused || !text.isEmpty ? .accentColor : .gray)
                .offset(y: (isFocused || !text.isEmpty) ? -22 : 0)
                .scaleEffect((isFocused || !text.isEmpty) ? 0.8 : 1, anchor: .leading)
                .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty)

            TextField("", text: $text)
                .focused($isFocused)
        }
        .padding(.top, 15)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
}


struct MultilineTextField: View {
    @State private var text = ""

    var body: some View {
        TextEditor(text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3))
            )
            .frame(height: 150)
            .padding()
    }
}


struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

struct StyledTextField: View {
    @State private var text = ""

    var body: some View {
        TextField("Имя", text: $text)
            .textFieldStyle(CustomTextFieldStyle())
    }
}


struct UIKitTextField: UIViewRepresentable {
    @State var text: String = ""

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Введите имя"
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UIKitTextField
        init(_ parent: UIKitTextField) { self.parent = parent }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}


struct ClearableTextField: View {
    @State private var text = ""

    var body: some View {
        HStack {
            TextField("Введите текст", text: $text)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
}


#Preview {
    ScrollView {
        BasicTextField()
        CustomPlainTextField()
        TextFieldWithIcon()
        PasswordField()
        FloatingLabelTextField()
        MultilineTextField()
        StyledTextField()
        UIKitTextField()
        ClearableTextField()
    }.padding(16)
}

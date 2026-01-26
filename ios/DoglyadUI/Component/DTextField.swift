import Combine
import SwiftUI

public class DTextFieldController: ObservableObject {
    @Published public var text: String = ""
    @Published fileprivate var isFocused: Bool = false
    @Published fileprivate var errorText: String? = nil

    public init(
        initialText: String = ""
    ) {
        self.text = initialText
    }

    public func focus() -> Void {
        isFocused = true
    }
    
    public func unfocus() -> Void {
        isFocused = false
    }
    
    public func showError(
        text: String
    ) -> Void {
        errorText = text
    }
}

public struct DTextField<Prefix: View, Postfix: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @FocusState private var isFocused: Bool
    private let title: LocalizedStringResource
    private let placeholder: LocalizedStringResource
    @ObservedObject private var controller: DTextFieldController
    private let keyboardType: UIKeyboardType
    private let sumbitLabel: SubmitLabel
    private let autocapitalization: TextInputAutocapitalization?
    private let prefix: (() -> Prefix)?
    private let postfix: (() -> Postfix)?

    public init(
        title: LocalizedStringResource,
        placeholder: LocalizedStringResource,
        controller: DTextFieldController,
        keyboardType: UIKeyboardType = .default,
        sumbitLabel: SubmitLabel = .done,
        autocapitalization: TextInputAutocapitalization? = .sentences,
    ) {
        self.title = title
        self.placeholder = placeholder
        self.controller = controller
        self.keyboardType = keyboardType
        self.sumbitLabel = sumbitLabel
        self.autocapitalization = autocapitalization
        self.prefix = nil
        self.postfix = nil
    }
    
    public init(
        title: LocalizedStringResource,
        placeholder: LocalizedStringResource,
        controller: DTextFieldController,
        keyboardType: UIKeyboardType = .default,
        sumbitLabel: SubmitLabel = .done,
        autocapitalization: TextInputAutocapitalization? = .sentences,
        @ViewBuilder prefix: @escaping (() -> Prefix),
        @ViewBuilder suffix: @escaping (() -> Postfix)
    ) {
        self.title = title
        self.placeholder = placeholder
        self.controller = controller
        self.keyboardType = keyboardType
        self.sumbitLabel = sumbitLabel
        self.autocapitalization = autocapitalization
        self.prefix = prefix
        self.postfix = suffix
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: size.s16)
                    .fill(fillColor)
                RoundedRectangle(cornerRadius: size.s16)
                    .stroke(borderColor, lineWidth: 1)

                HStack(spacing: .zero) {
                    prefix?().fixedSize()
                        .padding(.leading, size.s16)
                    
                    VStack(
                        alignment: .leading,
                        spacing: .zero
                    ) {
                        Text(title)
                            .font(.custom(.MontserratRegular, size.s10))
                            .foregroundStyle(titleColor)
                            .padding(.bottom, size.s2)
                        
                        TextField(
                            placeholder,
                            text: $controller.text,
                            prompt: Text(placeholder)
                                .foregroundStyle(color.grayscalePlaceholder),
                            axis: .vertical
                        )
                        .focused($isFocused)
                        .font(typography.textSmall)
                        .foregroundStyle(color.grayscaleHeader)
                        .multilineTextAlignment(.leading)
                        .tint(borderColor)
                        .lineLimit(8)
                        .keyboardType(keyboardType)
                        .submitLabel(sumbitLabel)
                        .textInputAutocapitalization(autocapitalization)
                    }

                    postfix?().fixedSize()
                        .padding(.leading, size.s16)
                }
                .padding(size.s10)
            }

            if let error = controller.errorText, !error.isEmpty {
                Text(error)
                    .font(typography.textSmall)
                    .foregroundStyle(color.dangerDefault)
                    .padding(.top, size.s4)
                    .padding(.horizontal, size.s16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(
            theme.animation,
            value: isFocused
        )
        .onTapGesture {
            controller.focus()
        }
        .onChange(of: isFocused) {
            guard isFocused != controller.isFocused else { return }
            controller.isFocused = isFocused
        }
        .onReceive(controller.$isFocused) { newValue in
            guard isFocused != controller.isFocused else { return }
            isFocused = controller.isFocused
        }
        .onChange(of: controller.text) {
            guard controller.errorText != nil else { return }
            controller.errorText = nil
        }
    }
}

private extension DTextField {
    var fillColor: Color {
        if controller.errorText != nil { return color.dangerBackground }
        return isFocused ? color.grayscaleBackground : color.grayscaleInput
    }

    var titleColor: Color {
        if controller.errorText != nil { return color.dangerDefault }
        return isFocused ? color.primaryDefault : color.grayscalePlaceholder
    }

    var borderColor: Color {
        if controller.errorText != nil { return color.dangerDefault }
        return isFocused ? color.primaryDefault : .clear
    }
}

#Preview {
    @Previewable let sampleText = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
    @Previewable @StateObject var controller = DTextFieldController()

    DThemeWrapperView {
        VStack {
            Spacer()
            DTextField<EmptyView, EmptyView>(
                title: "Some title",
                placeholder: "Some placeholder for filling...",
                controller: controller
            )
            Spacer()
            Button(
                "Show error"
            ) {
                controller.showError(text: "Some Error")
            }
            Button(
                "Set sample text"
            ) {
                controller.text = "\(Date())"
            }
        }
        .padding()
        .background(.gray)
        .onTapGesture {
            controller.unfocus()
        }
    }
}

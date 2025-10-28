//
//  DInput.swift
//  Doglyad
//
//  Created by Иван Галкин on 28.10.2025.
//

import Combine
import SwiftUI

public class DInputController: ObservableObject {
    @Published public var text: String = ""
    @Published fileprivate var isFocused: Bool = false
    @Published fileprivate var errorText: String? = nil

    public init() {}

    public func focus() {
        isFocused = true
    }

    public func unfocus() {
        isFocused = false
    }
}

public struct DInput<Content: View>: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @FocusState private var isFocused: Bool
    private let placeholder: String
    private let controller: DInputController
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization?
    private let prefix: (() -> Content)?
    private let postfix: (() -> Content)?

    public init(
        placeholder: String = "",
        controller: DInputController,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences,
    ) {
        self.placeholder = placeholder
        self.controller = controller
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.prefix = nil
        self.postfix = nil
    }
    
    public init(
        placeholder: String = "",
        controller: DInputController,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences,
        @ViewBuilder prefix: @escaping (() -> Content),
        @ViewBuilder suffix: @escaping (() -> Content)
    ) {
        self.placeholder = placeholder
        self.controller = controller
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.prefix = prefix
        self.postfix = suffix
    }

    public var body: some View {
        VStack(spacing: .zero) {
            ZStack {
                RoundedRectangle(cornerRadius: size.s16)
                    .fill(fillColor)
                RoundedRectangle(cornerRadius: size.s16)
                    .stroke(borderColor, lineWidth: 1)

                HStack(spacing: .zero) {
                    prefix?().fixedSize()

                    ZStack(alignment: .leading) {
                        DText(placeholder)
                            .dStyle(
                                font: typography.textXSmall,
                                color: placeholderColor
                            )
                            .offset(y: placeholderOffset)
                            .scaleEffect(placeholderScale, anchor: .leading)
                            .padding(.leading, 0)
                            .animation(
                                .easeOut(duration: 0.18),
                                value: placeholderShouldFloat
                            )
                        
                        TextField(
                            "",
                            text: Binding(
                                get: { controller.text },
                                set: { controller.text = $0 }
                            )
                        )
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .font(typography.textMedium)
                        .foregroundStyle(color.grayscaleHeader)
                        .multilineTextAlignment(.leading)
                        .tint(borderColor)
                    }

                    postfix?().fixedSize()
                }
                .padding(.horizontal, size.s16)
                .padding(.top, placeholderShouldFloat ? size.s12 : size.s16)
                .padding(.bottom, placeholderShouldFloat ? size.s4 : size.s16)
            }

            if let error = controller.errorText, !error.isEmpty {
                Text(error)
                    .font(typography.textSmall)
                    .foregroundStyle(color.dangerDefaultStrong)
            }
        }
        .frame(minHeight: size.s56)
        .fixedSize(horizontal: false, vertical: true)
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
    }
}

private extension DInput {
    var fillColor: Color {
        if controller.errorText != nil { return color.dangerBackground }
        return isFocused ? color.grayscaleBackground : color.grayscaleInput
    }

    var placeholderShouldFloat: Bool {
        isFocused || !controller.text.isEmpty
    }

    var placeholderOffset: CGFloat {
        placeholderShouldFloat ? -24 : 0
    }

    var placeholderScale: CGFloat {
        placeholderShouldFloat ? 0.85 : 1.0
    }

    var placeholderColor: Color {
        controller.errorText != nil ? color.dangerDefaultStrong : color.grayscaleLabel
    }

    var borderColor: Color {
        if controller.errorText != nil { return color.dangerDefault }
        return isFocused ? color.primaryDefault : .clear
    }
}

#Preview {
    @Previewable @StateObject var controller = DInputController()

    DThemeWrapperView {
        VStack {
            Spacer()
            DInput<EmptyView>(
                placeholder: "Some placeholder",
                controller: controller
            )
            Spacer()
        }
        .padding()
        .background(.gray)
        .onTapGesture {
            controller.unfocus()
        }
    }
}

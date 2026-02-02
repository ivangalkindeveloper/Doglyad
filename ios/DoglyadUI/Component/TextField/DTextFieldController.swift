import Combine
import SwiftUI

public class DTextFieldController: ObservableObject {
    @Published public var text: String = ""
    private let isRequired: Bool
    @Published var isError: Bool = false
    @Published var errorText: String? = nil

    public init(
        initialText: String = "",
        isRequired: Bool = false
    ) {
        text = initialText
        self.isRequired = isRequired
    }

    public func validate() -> Bool {
        errorText = nil
        if text.isEmpty && isRequired {
            isError = true
            return false
        }
        isError = false
        return true
    }

    public func showError(
        text: String
    ) {
        errorText = text
    }

    public func clear() {
        text = ""
    }
}

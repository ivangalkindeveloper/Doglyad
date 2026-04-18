import SwiftUI

@Observable
public class DTextFieldController {
    public var text: String = ""
    private let isRequired: Bool
    var isError: Bool = false
    var errorText: String?

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

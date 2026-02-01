import Combine
import SwiftUI

public class DTextFieldController: ObservableObject {
    @Published public var text: String = ""
    private let isRequired: Bool
    @Published var isError: Bool = false
    @Published var errorText: String? = nil

    public init(
        initialText: String = "",
        isRequired: Bool = false,
    ) {
        self.text = initialText
        self.isRequired = isRequired
    }
    
    public func validate() -> Bool {
        self.errorText = nil
        if self.text.isEmpty && self.isRequired {
            self.isError = true
            return false
        }
        self.isError = false
        return true
    }
    
    public func showError(
        text: String
    ) -> Void {
        self.errorText = text
    }
}

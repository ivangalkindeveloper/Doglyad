import SwiftUI
import Combine

public final class DMessager: ObservableObject {
    @Published var message: DMessage?
    
    public func show(
        type: DMessageType,
        title: LocalizedStringResource,
        description: LocalizedStringResource
    ) -> Void {
        self.message = DMessage(
            type: type,
            title: title,
            description: description
        )
    }
    
    public func hide() -> Void {
        self.message = nil
    }
}

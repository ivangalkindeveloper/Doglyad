import SwiftUI
import Combine

public final class DMessager: ObservableObject {
    @Published var message: DMessage?
    
    public func show(
        message: DMessage
    ) -> Void {
        self.message = message
    }
    
    public func hide() -> Void {
        self.message = nil
    }
}

import SwiftUI

@Observable
public final class DMessager {
    var message: DMessage?

    public func show(
        type: DMessageType,
        title: LocalizedStringResource,
        description: LocalizedStringResource? = nil
    ) {
        message = DMessage(
            type: type,
            title: title,
            description: description
        )
    }

    public func hide() {
        message = nil
    }
}

import SwiftUI
private import SwiftMessages

struct DMessageView<Content: View>: View  {
    @StateObject var messager = DMessager()
    
    @ViewBuilder let content: () -> Content
    
    init(
        content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    var body: some View {
        content()
            .swiftMessage(message: $messager.message) { message in
                DErrorMessage()
            }
            .environmentObject(messager)
    }
}

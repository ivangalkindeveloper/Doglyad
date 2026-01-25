import SwiftUI
import AVFoundation

public struct DCameraView: UIViewRepresentable {
    var controller: DCameraController
    
    public init(
        controller: DCameraController
    ) {
        self.controller = controller
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        controller.previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(controller.previewLayer)
        return view
    }

    public func updateUIView(
        _ uiView: UIView,
        context: Context
    ) -> Void {}
}

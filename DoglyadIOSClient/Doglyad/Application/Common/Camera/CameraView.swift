//
//  AnamnesisCameraView.swift
//  Doglyad
//
//  Created by Иван Галкин on 07.10.2025.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        viewModel.previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(viewModel.previewLayer)
        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: Context
    ) {}
}

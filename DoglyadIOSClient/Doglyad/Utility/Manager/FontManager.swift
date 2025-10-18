//
//  FontRegistrar.swift
//  Doglyad
//
//  Created by Иван Галкин on 14.10.2025.
//

import Foundation
import SwiftUI

protocol FontManagerProtocol: AnyObject {
    func registerFonts() -> Void
    
    func registerFont(named name: String, fileExtension: String) -> Void
}

final class FontManager {}

extension FontManager: FontManagerProtocol {
    func registerFonts() -> Void {
        registerFont(named: "Poppins-Regular", fileExtension: "ttf")
        registerFont(named: "Poppins-Medium", fileExtension: "ttf")
        registerFont(named: "Poppins-SemiBold", fileExtension: "ttf")
        registerFont(named: "Poppins-Bold", fileExtension: "ttf")
        
    }

    func registerFont(named name: String, fileExtension: String) -> Void {
        let bundle = Bundle(for: InitializationProcess.self)
        guard let fontURL = bundle.url(forResource: name, withExtension: fileExtension),
              let dataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(dataProvider)
        else {
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("⚠️ Ошибка регистрации шрифта \(name): \(String(describing: error))")
        }
    }
}

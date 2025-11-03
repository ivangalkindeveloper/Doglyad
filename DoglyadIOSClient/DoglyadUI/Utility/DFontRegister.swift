import Foundation
import SwiftUI

public protocol DFontRegisterProtocol: AnyObject {
    static func registerFonts(
        bundle: Bundle,
    ) -> Void
}

public final class DFontRegister {}

extension DFontRegister: DFontRegisterProtocol {
     public static func registerFonts(
        bundle: Bundle,
    ) -> Void {
        register(bundle, "Poppins-Regular", "ttf")
        register(bundle, "Poppins-Medium", "ttf")
        register(bundle, "Poppins-SemiBold", "ttf")
        register(bundle, "Poppins-Bold", "ttf")
        
    }

    static func register(
        _ bundle: Bundle,
        _ name: String,
        _ fileExtension: String
    ) -> Void {
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

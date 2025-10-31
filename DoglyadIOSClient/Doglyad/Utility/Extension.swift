//
//  Utility.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import Foundation
import UIKit
import SystemConfiguration

extension Bundle {
    enum KeyString: String {
        case BASE_URL_SCHEMA
        case BASE_URL
    }
    
    static func dictionaryString(
        _ key: KeyString
    ) -> String {
        main.object(forInfoDictionaryKey: key.rawValue) as! String
    }
}

extension UIApplication {
    static func openSettings() {
        guard let settingsURL = URL(string: openSettingsURLString) else { return }
        if shared.canOpenURL(settingsURL) {
            shared.open(settingsURL)
        }
    }
}

extension LocalizedStringResource {
    static func forUSResearchType(
        _ type: USResearchType,
    ) -> LocalizedStringResource {
        switch type {
        case USResearchType.thyroidGland:
                .researchTypeThyroidGland
        }
    }
}

//
//  Utility.swift
//  Doglyad
//
//  Created by Иван Галкин on 12.10.2025.
//

import Foundation

extension Bundle {
    enum KeyString: String {
        case BASE_URL_SCHEMA
        case BASE_URL
    }
    
    static func dictionaryString(
        _ key: KeyString
    ) -> String {
        Bundle.main.object(forInfoDictionaryKey: key.rawValue) as! String
    }
}

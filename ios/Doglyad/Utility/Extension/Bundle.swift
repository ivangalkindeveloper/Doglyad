import Foundation

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

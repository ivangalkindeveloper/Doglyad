import Foundation

extension Bundle {
    enum KeyString: String {
        case BASE_URL_SCHEMA
        case BASE_URL
        case CFBundleShortVersionString
        case CFBundleVersion
    }

    static func dictionaryString(
        _ key: KeyString
    ) -> String {
        main.object(forInfoDictionaryKey: key.rawValue) as! String
    }

    static var shortVersion: Version {
        let parts = dictionaryString(.CFBundleShortVersionString).split(separator: ".").compactMap { Int($0) }
        guard parts.count >= 3 else { return .default }
        return Version(major: parts[0], minor: parts[1], patch: parts[2])
    }
}

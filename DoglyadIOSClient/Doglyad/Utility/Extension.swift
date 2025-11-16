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
    static func forResearchType(
        _ type: ResearchType,
    ) -> LocalizedStringResource {
        switch type {
        case ResearchType.thyroidGland:
                .researchTypeThyroidGland
        case ResearchType.abdominalCavity:
                .researchTypeAbdominalCavity
        case ResearchType.kidneysAdrenalGlandsAndRetroperitonealSpace:
                .researchTypeKidneysAdrenalGlandsAndRetroperitonealSpace
        case ResearchType.bladder:
                .researchTypeBladder
        default:
                .researchTypeThyroidGland
        }
    }
    
    static func forGender(
        _ gender: PatientGender,
    ) -> LocalizedStringResource {
        switch gender {
        case PatientGender.male:
                .scanGenderMaleLabel
        case PatientGender.female:
                .scanGenderFemaleLabel
        }
    }
}

extension Date {
    func localized(
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

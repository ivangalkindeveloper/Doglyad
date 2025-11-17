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
        case ResearchType.abdominalCavity:
                .researchTypeAbdominalCavity
        case ResearchType.abdominalVessels:
                .researchTypeAbdominalVessels
        case ResearchType.arteriesOfTheLowerExtremities:
                .researchTypeArteriesOfTheLowerExtremities
        case ResearchType.arteriesOfTheUpperExtremities:
                .researchTypeArteriesOfTheUpperExtremities
        case ResearchType.bladder:
                .researchTypeBladder
        case ResearchType.bladderWithResidualUrineDetermination:
                .researchTypeBladderWithResidualUrineDetermination
        case ResearchType.brachiocephalicVessels:
                .researchTypeBrachiocephalicVessels
        case ResearchType.echocardiography:
                .researchTypeEchocardiography
        case ResearchType.eye:
                .researchTypeEye
        case ResearchType.hipJointsInNewborns:
                .researchTypeHipJointsInNewborns
        case ResearchType.hollowOrgansStomachAndIntestines:
                .researchTypeHollowOrgansStomachAndIntestines
        case ResearchType.intracanialArteries:
                .researchTypeIntracanialArteries
        case ResearchType.joints:
                .researchTypeJoints
        case ResearchType.kidneysAdrenalGlandsAndRetroperitonealSpace:
                .researchTypeKidneysAdrenalGlandsAndRetroperitonealSpace
        case ResearchType.lymphNodes:
                .researchTypeLymphNodes
        case ResearchType.mammaryGlands:
                .researchTypeMammaryGlands
        case ResearchType.neurosonography:
                .researchTypeNeurosonography
        case ResearchType.pelvicOrgans:
                .researchTypePelvicOrgans
        case ResearchType.pleuralRegion:
                .researchTypePleuralRegion
        case ResearchType.renalArteries:
                .researchTypeRenalArteries
        case ResearchType.salivaryGlands:
                .researchTypeSalivaryGlands
        case ResearchType.scrotum:
                .researchTypeScrotum
        case ResearchType.sinuses:
                .researchTypeSinuses
        case ResearchType.softTissues:
                .researchTypeSoftTissues
        case ResearchType.thymusGland:
                .researchTypeThymusGland
        case ResearchType.thyroidGland:
                .researchTypeThyroidGland
        case ResearchType.veinsOfTheLowerExtremities:
                .researchTypeVeinsOfTheLowerExtremities
        case ResearchType.veinsOfTheUpperExtremities:
                .researchTypeVeinsOfTheUpperExtremities
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

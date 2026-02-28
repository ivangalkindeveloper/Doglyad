import Foundation

extension LocalizedStringResource {
    static func forExaminationTypeById(
        types: [String: USExaminationType],
        id: String,
        locale: Locale
    ) -> LocalizedStringResource {
        types[id]?.getLocalizedTitle(for: locale) ?? ""
    }
    
    static func forGender(
        _ gender: PatientGender
    ) -> LocalizedStringResource {
        switch gender {
        case PatientGender.male:
            .scanGenderMaleLabel
        case PatientGender.female:
            .scanGenderFemaleLabel
        }
    }
}

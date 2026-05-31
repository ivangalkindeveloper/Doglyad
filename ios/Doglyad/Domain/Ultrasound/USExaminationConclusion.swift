import DoglyadDatabase
import Foundation

struct USExaminationConclusion: Identifiable, Codable {
    var id: UUID = .init()
    let date: Date
    let neuralModelSettings: NeuralModelSettings
    let examinationData: USExaminationData
    let actualModelConclusion: USExaminationModelConclusion
    let previosModelConclusions: [USExaminationModelConclusion]
}

private extension USExaminationConclusion {
    enum CodingKeys: String, CodingKey {
        case date,
             neuralModelSettings,
             examinationData,
             actualModelConclusion,
             previosModelConclusions
    }
}

extension USExaminationConclusion {
    func shareSubject(
        examinationTypesById: [String: USExaminationType],
        locale: Locale = .current
    ) -> String {
        let examinationType = String(
            localized: .forExaminationTypeById(
                types: examinationTypesById,
                id: examinationData.usExaminationTypeId,
                locale: locale
            )
        )
        return "Doglyad: \(date.localized()) \(examinationData.patientName) \(examinationType)"
    }

    var shareMessage: String {
        var lines: [String] = [
            "\(String(localized: .scanExaminationDateLabel))\n\(date.localized())",
            "\(String(localized: .scanPatientNameLabel))\n\(examinationData.patientName)",
            "\(String(localized: .scanPatientGenderLabel))\n\(String(localized: .forGender(examinationData.patientGender)))",
            "\(String(localized: .scanPatientDateOfBirthLabel))\n\(examinationData.patientDateOfBirth.localized())",
            "\(String(localized: .scanExaminationDescriptionLabel))\n\(examinationData.examinationDescription)"
        ]
        if let patientComplaint = examinationData.patientComplaint {
            lines.append("\(String(localized: .scanPatientComplaintLabel))\n\(patientComplaint)")
        }
        if let additionalData = examinationData.additionalData {
            lines.append("\(String(localized: .scanAdditionalDataLabel))\n\(additionalData)")
        }

        lines.append("\(String(localized: .conclusionActualModelResponseTitle))\n\(actualModelConclusion.response)")

        if !previosModelConclusions.isEmpty {
            lines.append(String(localized: .conclusionPreviosModelResponsesTitle))
            for modelConclusion in previosModelConclusions {
                lines.append(modelConclusion.response)
            }
        }

        return lines.joined(separator: "\n\n")
    }

    static func fromDB(
        _ db: USExaminationConclusionDB
    ) -> USExaminationConclusion {
        USExaminationConclusion(
            id: db.id,
            date: db.date,
            neuralModelSettings: NeuralModelSettings.fromDB(db.neuralModelSettings),
            examinationData: USExaminationData.fromDB(db.examinationData),
            actualModelConclusion: USExaminationModelConclusion.fromDB(db.actualModelConclusion),
            previosModelConclusions: db.previosModelConclusions.map { USExaminationModelConclusion.fromDB($0) }
        )
    }

    func toDB() -> USExaminationConclusionDB {
        USExaminationConclusionDB(
            id: id,
            date: date,
            neuralModelSettings: neuralModelSettings.toDB(),
            examinationData: examinationData.toDB(),
            actualModelConclusion: actualModelConclusion.toDB(),
            previosModelConclusions: previosModelConclusions.map { $0.toDB() }
        )
    }
}

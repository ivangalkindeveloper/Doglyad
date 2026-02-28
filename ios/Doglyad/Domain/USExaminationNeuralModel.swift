import Foundation

struct USExaminationNeuralModel: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: [String: String]

    func getLocalizedDescription(for locale: Locale) -> LocalizedStringResource {
        let key = locale.language.languageCode?.identifier ?? "en"
        let description = description[key] ?? description.values.first ?? ""
        return LocalizedStringResource(stringLiteral: description)
    }
}

extension USExaminationNeuralModel {
    static let `default`: Self = .init(
        id: "google/medgemma-27b-it",
        title: "Google MedGemma 27B",
        description: [
            "en": "Google's multimodal medical AI-model Gemma 3. Trained on de-identified medical data: X-rays, dermatology, ophthalmology, histopathology, medical text and EHR. Handles images and text.",
            "ru": "Мультимодальная медицинская ИИ-модель Google Gemma 3. Обучена на обезличенных данных: рентген, дерматология, офтальмология, гистология, медицинские тексты и ЭМК. Работает с изображениями и текстом.",
        ]
    )
}
